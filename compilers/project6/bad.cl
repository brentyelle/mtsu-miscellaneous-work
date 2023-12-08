class C {
	a : UndefinedType;
	b : Bool;
	init(x : Int, y : Bool) : C {
           {
		a <- x;
		b <- y;
		undefinedvariable <- 1;
		b <- 1;
		1 + "a string";
		1 < "a string";
		self;
           }
	};
	test(x : UndefinedType) : C {
           {
		1;
		not "a string";
           }
	};
};

Class Main {
	main():C {
	 {
	  (new C).init(1,1);
	  (new C).init(1,true,3);
	  (new C).iinit(1,true);
	  (new C);
	 }
	};
};
