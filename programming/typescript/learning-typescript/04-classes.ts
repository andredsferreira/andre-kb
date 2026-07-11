/**
 * By default the fields of a class are public;
 * If you are setting private fields you can decide how they are accessed 
 * or modified through the use of getters and setters;
 */

class User {

  name: string;
  age: number;
  isAdmin: boolean;

  constructor(name: string, age: number, isAdmin: boolean) {
    this.name = name;
    this.age = age;
    this.isAdmin = isAdmin;
  }

  userDisplay(): void {
    console.log(`Name: ${this.name}, Age: ${this.age}, Admin: ${this.isAdmin}\n`);
  }
}

class UserPrivate {

  private _name: string;
  private _age: number;
  private _isAdmin: boolean;

  constructor(name: string, age: number, isAdmin: boolean) {
    this._name = name;
    this._age = age;
    this._isAdmin = isAdmin;
  }

  userPrivateDisplay(): void {
    console.log(`Name: ${this._name}, Age: ${this._age}, Admin: ${this._isAdmin}\n`);
  }
}

let uA = new User('Andrew Morrison', 23, false);
let uB = new UserPrivate('Jim Morrison', 27, true);

uA.userDisplay();
uB.userPrivateDisplay();