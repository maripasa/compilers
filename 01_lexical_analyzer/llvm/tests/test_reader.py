import ctypes as C
from pathlib import Path
import tempfile
import unittest

from llvmlite import binding as llvm

ROOT = Path(__file__).resolve().parents[1]
llvm.initialize_native_target()
llvm.initialize_native_asmprinter()
module = llvm.parse_assembly((ROOT / 'reader.ll').read_text())
module.verify()
engine = llvm.create_mcjit_compiler(
    module, llvm.Target.from_default_triple().create_target_machine())
engine.finalize_object()


class Reader(C.Structure):
    _fields_ = [
        ('file', C.c_void_p), ('b0', C.c_void_p), ('b1', C.c_void_p),
        ('active', C.c_bool), ('forward', C.c_uint64),
        ('begin_buffer', C.c_bool), ('begin', C.c_uint64),
        ('valid0', C.c_uint64), ('valid1', C.c_uint64),
        ('eof', C.c_bool), ('collecting', C.c_bool), ('error', C.c_int32),
    ]


class Lexeme(C.Structure):
    _fields_ = [('first', C.c_void_p), ('n1', C.c_uint64),
                ('second', C.c_void_p), ('n2', C.c_uint64)]

    def bytes(self):
        return C.string_at(self.first, self.n1) + C.string_at(self.second, self.n2)


def function(name, result, *args):
    return C.CFUNCTYPE(result, *args)(engine.get_function_address(name))


init = function('reader_init', C.c_void_p, C.c_void_p, C.c_char_p)
destroy = function('reader_destroy', None, C.c_void_p)
peek = function('reader_peek', C.c_int32, C.c_void_p)
step = function('reader_step', None, C.c_void_p)
begin = function('reader_begin', None, C.c_void_p)
lexeme = function('reader_lexeme', C.c_bool, C.c_void_p, C.c_void_p)


class ReaderTests(unittest.TestCase):
    def open_reader(self, data):
        file = tempfile.NamedTemporaryFile()
        file.write(data)
        file.flush()
        reader = Reader()
        self.assertTrue(init(C.byref(reader), file.name.encode()))
        self.addCleanup(file.close)
        self.addCleanup(destroy, C.byref(reader))
        return reader

    def consume(self, reader, data):
        for byte in data:
            self.assertEqual(peek(C.byref(reader)), byte)
            self.assertEqual(peek(C.byref(reader)), byte)
            step(C.byref(reader))

    def token(self, reader, data):
        begin(C.byref(reader))
        self.consume(reader, data)
        result = Lexeme()
        self.assertTrue(lexeme(C.byref(reader), C.byref(result)))
        self.assertEqual(result.bytes(), data)
        return result

    def test_streams_and_examples(self):
        streams = [bytes(i % 256 for i in range(n))
                   for n in (0, 1, 127, 128, 129, 255, 256, 257, 1025)]
        streams += [p.read_bytes() for p in (ROOT / 'examples').glob('*.java')]
        for data in streams:
            with self.subTest(length=len(data)):
                r = self.open_reader(data)
                self.consume(r, data)
                for _ in range(2):
                    self.assertEqual(peek(C.byref(r)), -1)
                    step(C.byref(r))

    def test_spans_in_both_directions_and_begin_at_boundary(self):
        data = bytes(i % 256 for i in range(500))
        r = self.open_reader(data)
        self.token(r, data[:120])
        result = self.token(r, data[120:140])
        self.assertEqual((result.n1, result.n2), (8, 12))
        self.token(r, data[140:250])
        result = self.token(r, data[250:270])
        self.assertEqual((result.n1, result.n2), (6, 14))
        self.token(r, data[270:384])
        result = self.token(r, data[384:400])
        self.assertEqual((result.n1, result.n2), (16, 0))

    def test_boundary_lookahead_preserves_lexeme(self):
        r = self.open_reader(b'a' * 128 + b'!')
        begin(C.byref(r))
        self.consume(r, b'a' * 128)
        self.assertEqual(peek(C.byref(r)), ord('!'))
        result = Lexeme()
        self.assertTrue(lexeme(C.byref(r), C.byref(result)))
        self.assertEqual(result.bytes(), b'a' * 128)

    def test_overflow_preserves_buffers(self):
        r = self.open_reader(b'a' * 256 + b'b')
        begin(C.byref(r))
        self.consume(r, b'a' * 256)
        before = C.string_at(r.b0, 128)
        self.assertEqual(peek(C.byref(r)), -2)
        step(C.byref(r))
        self.assertEqual(peek(C.byref(r)), -2)
        self.assertEqual(C.string_at(r.b0, 128), before)
        result = Lexeme()
        self.assertFalse(lexeme(C.byref(r), C.byref(result)))
        self.assertEqual((result.n1, result.n2), (0, 0))

    def test_full_wrap_is_too_long(self):
        r = self.open_reader(b'a' * 256 + b'!')
        begin(C.byref(r))
        self.consume(r, b'a' * 256)
        self.assertEqual(peek(C.byref(r)), -2)
        result = Lexeme()
        self.assertFalse(lexeme(C.byref(r), C.byref(result)))

    def test_missing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            r = Reader()
            self.assertFalse(init(C.byref(r), str(Path(directory) / 'missing').encode()))


if __name__ == '__main__':
    unittest.main()
