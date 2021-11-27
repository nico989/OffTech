import java.io.File;
import java.io.FileWriter;
import java.security.MessageDigest;

class InputControls implements Runnable {
   private FileClient gui;

   public InputControls(FileClient in) {
      this.gui = in;
   }

   public void run() {
      String username = this.gui.usernameText;
      String password = this.gui.passwordText;
      String serverName = this.gui.serverText;
      String jarName = this.gui.fileText;

      try {
         MessageDigest var5 = MessageDigest.getInstance("MD5");
      } catch (Exception var10) {
         System.out.println("Unable to create message hash");
         var10.printStackTrace();
      }

      try {
         ConnectionHandler connection = new ConnectionHandler();
         String reply = connection.connect(username, password, jarName, serverName, this.gui.length);
         if (reply.length() < 1) {
            System.out.print("Error Recovering Information.\n");
            return;
         }

         if (reply.equals("R573..&27")) {
            System.out.print("You Cannot Access This Information.\n");
            return;
         }

         if (reply.equals("+-jR3&22")) {
            System.out.print("You Cannot Access This Information at This Time.\n");
            return;
         }

         if (reply.equals("+-jR3&12")) {
            System.out.print("Some error has occured.\n");
            return;
         }

         FileWriter file = new FileWriter(jarName);
         file.write(reply);
         file.close();
         System.out.print("File has been received correctly.\n");
      } catch (Exception var9) {
         System.out.println("Error Recovering File");
         var9.printStackTrace();
      }

      try {
         File tempFile = new File("." + File.separator + "_" + jarName);
         tempFile.delete();
      } catch (Exception var8) {
         System.out.print("Error Deleting Temporary File\n");
         var8.printStackTrace();
      }

   }
}
