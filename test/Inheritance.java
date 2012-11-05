package test;

public class Inheritance {
	public static void main(String[] args) {
		BChild child = new BChild();
		child.a = 3;
		child.b = 5;
		System.out.println("Child a: " + child.a);
		System.out.println("Parent a through child via getter: " + child.getA());
		System.out.println("Child b: " + child.b);
		AParent par = child;
		par.a = 4;
		System.out.println("Parent a: " + par.a);
		System.out.println("Parent a through getter: " + par.getA());
		System.out.println("Parent b: " + par.b);
		BChild child2 = (BChild) par;	
		System.out.println("Child a: " + child2.a);
		System.out.println("Parent a through child via getter: " + child2.getA());
		System.out.println("Child b: " + child2.b);
	}
}

class AParent {
	public int a;
	public int b;
	int getA() {
		return a;
	}
}

class BChild extends AParent {
	public int a;
}

