#include<iostream>
using namespace std;

// 1. Using Virtual function + base ptr + derived objects = runtime polymorphism
class Base{
    public:
    virtual void show(){
        cout<<"Base";
    }
};

class Derived: public Base{
    public:
    void show() override{
        cout<<"Derived";
    }
};


//Without virtual functions: it's being static binding at compile time
class Animal{
    public:
    void show(){
        cout<<"Animal";
    }
};


//2. copy constructor

class Student{
    int id;
    string name;
public:
    Student(int i, string n){   //normal constructor function
        id = i;
        name = n;
        cout<<"Constructor Called\n";
    }
    
    Student(const Student& other){  //copy constructor function
        id = other.id;
        name = other.name;
        cout<<"Copy Constructor Called\n";
    }

    void show(){
        cout << "ID: " << id << ", Name: " << name << endl;
    }
};

class Dog: public Animal{
    public:
    void show() {
        cout<<"Dog";
    }
};



int main(){

    // Base* ptr  = new Derived();
    // ptr->show();

    // Animal* ptr = new Dog();
    // ptr->show();

    Student s1(596, "Rajan");   //normal constructor
    Student s2 = s1;    //copy constructor
    Student s3(s1);     //copy constructor

    s1.show();
    s2.show();
    s3.show();
    
    return 0;
}