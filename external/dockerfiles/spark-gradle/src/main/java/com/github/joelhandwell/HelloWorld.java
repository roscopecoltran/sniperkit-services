package com.github.joelhandwell;

import static spark.Spark.*;

public class HelloWorld {
	public static void main (String args[]){
		Today today = new Today();
		System.out.println("hello world! today is " + today.date());
		get("/hello", (req, res) -> "Hello World! today is " + today.date());
	}
}
