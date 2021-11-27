import java.util.Random;

public class FileClient {
   protected String usernameText = new String();
   protected String passwordText = new String();
   protected String serverText = new String();
   protected String fileText = new String();
   protected int length;

   public static void main(String[] args) {
      FileClient gui = new FileClient();
      if (args.length >= 4) {
         gui.usernameText = args[0];
         gui.passwordText = args[1];
         gui.serverText = args[2];
         gui.fileText = args[3];
         if (args.length >= 5) {
            try {
               gui.length = Integer.parseInt(args[4]);
            } catch (Exception var3) {
               System.err.print("Failed to read length, using zero instead.\n");
               gui.length = 0;
            }
         } else {
            Random rand = new Random();
            gui.length = rand.nextInt(2000);
         }

         InputControls controls = new InputControls(gui);
         controls.run();
         System.exit(1);
      }

   }
}
