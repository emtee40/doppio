package classes.test;

import java.util.Arrays;
import java.lang.reflect.*;

class Clinit {
  static void printMethods(Method[] methods) {
    String[] names = new String[methods.length];
    for (int i=0; i<names.length; ++i) {
      names[i] = methods[i].getName();
    }
    Arrays.sort(names);
    for (String n : names) {
      System.out.println(n);
    }
  }
  public static void main(String[] args) throws ClassNotFoundException {
    System.out.println("Declared methods for class ClinitBar:");
    printMethods(ClinitBar.class.getDeclaredMethods());
    System.out.println("\nPublic methods for class ClinitBar:");
    printMethods(ClinitBar.class.getMethods());

    ClinitFoo cf = null;
    System.out.println(cf instanceof ClinitBar);
  }
}

class ClinitFoo {
  static {
    // should not get called
    System.out.println("initializing class ClinitFoo");
  }
  void foo() {};
  public void pubFoo() {};
}

class ClinitBar extends ClinitFoo {
  static {
    // should not get called
    System.out.println("initializing class ClinitBar");
  }
  void bar() {};
  public void pubBar() {};
}
