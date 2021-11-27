import java.io.EOFException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.net.Socket;
import java.net.SocketException;
import java.util.Random;
import javax.net.SocketFactory;

class ConnectionHandler {
   private static final int port = 7777;
   private static final String DELIMINATOR = "!:.:!";
   public static final String NO_PERMISSION_STRING = "R573..&27";
   public static final String TIME_PERMISSION_STRING = "+-jR3&22";
   public static final String GENERIC_ERROR_STRING = "+-jR3&12";

   public String connect(String username, String password, String fileName, String serverName, int size) {
      String message = "";
      StringBuilder junk = new StringBuilder();
      Random rand = new Random();
      rand.nextInt(122);

      for(int i = 0; i < size; ++i) {
         junk.append(String.valueOf((char)rand.nextInt(126)));
      }

      try {
         SocketFactory factory = SocketFactory.getDefault();
         Socket socket = factory.createSocket(serverName, 7777);
         ObjectOutputStream outputStream = new ObjectOutputStream(socket.getOutputStream());
         outputStream.writeObject(username + "!:.:!" + password + "!:.:!" + fileName + "!:.:!" + junk.toString());
         ObjectInputStream inputStream = new ObjectInputStream(socket.getInputStream());
         message = (String)inputStream.readObject();
         inputStream.close();
         outputStream.close();
         socket.close();
      } catch (SocketException var13) {
         System.err.print("Connection Timed Out\n");
      } catch (EOFException var14) {
         System.err.print("Connection Interrupted Unexpectedly\n");
      } catch (Exception var15) {
         var15.printStackTrace();
         message = "+-jR3&12";
      }

      return message;
   }
}
