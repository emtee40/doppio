/**
 * A simple TCP server that capitalizes and sends back lines of text sent to it.
 * Adapted from http://systembash.com/content/a-simple-java-tcp-server-and-tcp-client/
 */
package classes.util;

import java.io.*;
import java.net.*;

class TCPServer  {
  public static void main(String argv[]) throws Exception {
    ServerSocket welcomeSocket = new ServerSocket(argv.length > 0 && argv[0].equals("doppio") ? 7002 : 7001);
    Runtime.getRuntime().addShutdownHook(new Thread() {
      @Override
      public void run() {
        try {
          welcomeSocket.close();
        } catch (IOException e) {
        }
      }
    });

    while(true) {
      try {
        final Socket connectionSocket = welcomeSocket.accept();
        // wait 3 minutes before timeout.
        connectionSocket.setSoTimeout(180*1000);
        final BufferedReader inFromClient =
            new BufferedReader(new InputStreamReader(connectionSocket.getInputStream()));
        final DataOutputStream outToClient = new DataOutputStream(connectionSocket.getOutputStream());
        Runnable task = () -> {
          try {
            while(true) {
              String clientSentence = inFromClient.readLine();
              String capitalizedSentence = clientSentence.toUpperCase() + '\n';
              outToClient.writeBytes(capitalizedSentence);
            }
          } catch (Throwable t) {
            System.out.println(t);
          }
        };
        new Thread(task).start();
      } catch (Throwable t) {
        System.out.println(t);
      }
    }
  }
}
