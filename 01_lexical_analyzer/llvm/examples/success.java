public class SuccessExample {
    public static void main(String[] args) {
        int count = 3;
        float rate = 3.14;
        char newline = '\n';
        String message = "texto\n";
        boolean ready = true;

        // This comment must be ignored.
        if (ready && count >= 1) {
            count += 1;
        } else {
            count = count * 2;
        }

        /* This comment must also be ignored. */
        return;
    }
}
