// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
library Structures {
    enum Roles {
        guest,
        student,
        teac,
        admin
    }
    enum Class {
        x,
        a,
        b,
        c
        
    }
    
    struct user {
    string login;
    string password;
    string FIO;
    Roles role;
    Class class;
    }
    
    
   
    struct mark {
        uint id;
        uint8 grade;
        string datatime;
    }
    struct homework {
        uint id;
        string namepredmet;
        string nametask;
        string task;
        string datatime;
        bool done;
    }
    struct timetable{
        uint id;
        string week;
        string namepredmet1;
        string namepredmet2;
        string namepredmet3;
        string namepredmet4;
        string namepredmet5;
        string namepredmet6;
        string namepredmet7;
        string namepredmet8;
        
    }
    
}

contract scholl  {
  mapping(address=>Structures.user)user;//маппинг пользователя
  mapping(address=>mapping(string=>Structures.mark[]))database;//маппинг оценок
  mapping(Structures.Class =>Structures.homework [])dz;//маппинг домашнего задания 
  mapping(Structures.Class =>Structures.timetable [])timetable;
 
  constructor(string memory login ,string memory password,string memory FIO, address add) public  {
      user[add] = Structures.user(login,password,FIO,Structures.Roles.admin,Structures.Class.x);
  }
  // требование на зарегистрированого пользователя
  modifier noguest {
      require(user[msg.sender].role != Structures.Roles.guest,"Вы не зарегистрированы");
      _;
  }
  // требование на админа
  modifier onlyadmin {
      require(user[msg.sender].role == Structures.Roles.admin,"Вы не админ");
      _;
  }
  //требование на учителя
  modifier onlyteac {
      require(user[msg.sender].role == Structures.Roles.teac ,"Вы не учитель");
      _;
  }
  //функция регистрации пользователя
  function reg (string memory login ,string memory password,string memory FIO) public  {
      require(user[msg.sender].role == Structures.Roles.guest,"Вы уже зарегистрированны");
      require(bytes(login).length >= 3,"Логин должен быть больше 3 символов" );
      require(bytes(password).length >= 3 ,"Пароль должен быть больше 3 символов");
      require(bytes(FIO).length > 0 ,"Заполните поле ФИО");
      user[msg.sender] = Structures.user(login,password,FIO,Structures.Roles.student,Structures.Class.x);
  }
  //функция авторизации пользователя
  function aut (string memory login , string memory password) public view noguest {
      require(bytes(login).length >= 3,"Логин должен быть больше 3 символов");
      require(bytes(password).length >= 3 ,"Пароль должен быть больше 3 символов");
      require(keccak256(bytes(user[msg.sender].login)) == keccak256(bytes(login)),"Не верный логин");
      require(keccak256(bytes(user[msg.sender].password))== keccak256(bytes(password)),"Не верный пароль");
  }
  //функция просмотра личного кабинета 
  function getlk() public noguest view returns(string memory login,string memory FIO,Structures.Roles,Structures.Class){
      return(user[msg.sender].login,user[msg.sender].FIO,user[msg.sender].role,user[msg.sender].class);
  }
  //функция просмотра личного кабинета других пользователей (доступна только работникам)
  function getlkuser (address add) public view returns(string memory login,string memory FIO,Structures.Roles,Structures.Class){
      require(user[msg.sender].role == Structures.Roles.teac || user[msg.sender].role == Structures.Roles.admin,"Ошибка у вас не прав");
     return(user[add].login,user[add].FIO,user[add].role,user[add].class) ;
  }
  //функция добавления учителя доступна только админу 
  function addteac(address add) public onlyadmin{
      require(user[add].role != Structures.Roles.guest,"Пользователь не зарегистрирован");
      user[add].role = Structures.Roles.teac;
      
  }
  //функция условного удаление пользователя
  function remuveuser(address add) public onlyadmin {
      user[add].role = Structures.Roles.guest;
      user[add].class = Structures.Class.x;
  }
  //функция передачи прав администратора другому пользователю 
  function newadmin(address add) public onlyadmin {
      require(user[add].role != Structures.Roles.guest,"Пользователь не зарегистророван");
      user[add].role = Structures.Roles.admin;
      user[msg.sender].role = Structures.Roles.guest;
  }
//функция добавления оценок 
  function addgrade(address add,string memory predmet,uint8 grade,string memory datatime) public onlyteac {
      require(bytes(predmet).length > 0 ,"Поле предмет не может быть пустым ");
      require(grade >1 && grade < 6,"оценка должна равняться 2-5");
      require(bytes(datatime).length > 0,"Укажите дату" );
       require(user[msg.sender].class == user[add].class," вы не учитель этого класса");
      database[add][predmet].push(Structures.mark(database[add][predmet].length,grade,datatime));
  }
  //функция изменения класса пользователя
  function addclass(address add,Structures.Class z)public onlyadmin returns(string memory){
     require(user[add].role != Structures.Roles.guest,"Пользователь не зарегистрирован");
     user[add].class = z;
    }
    //функция просмотра оценок пользователя
  function getgrade(string memory premet)public noguest view returns(Structures.mark [] memory) {
      return (database[msg.sender][premet]);
  }
  //функция просмотра оценок всех  учеников доступна только учителю 
  function getgradeclass(address add,string memory predmet)public view onlyteac returns(Structures.mark [] memory) {
      return(database[add][predmet]);
  }
  //функция удаления оценок 
  function remuvegrade(uint id ,address add,string memory predmet) public onlyteac {
      require(bytes(predmet).length > 0,"Поле предмет не может быть пустым");
      require(id >=0,"Поле ID не может быть пустым");
      for(uint i = id; id< database[add][predmet].length - 1; i ++){
         database[add][predmet][i] = database[add][predmet][i+1];
         database[add][predmet][id--];
      }
    delete database[add][predmet][database[add][predmet].length -1]; 
    }
    //функция добавления домашнего задания 
    function addhomework(string memory namepredmet,string memory nametask,string memory task,string memory datatime)public onlyteac {
        require(bytes(namepredmet).length >0,"Поля не могут быть пустыми");
        require(bytes(nametask).length >0,"Поля не могут быть пустыми");
        require(bytes(task).length >0,"Поля не могут быть пустыми");
        require(bytes(datatime).length >0,"Поля не могут быть пустыми");
        dz[user[msg.sender].class].push(Structures.homework(dz[user[msg.sender].class].length,namepredmet,nametask,task,datatime,false));
    }
    //функция просмотра домашнего задания 
function gethomework() public noguest view returns(Structures.homework [] memory){
    return(dz[user[msg.sender].class]);
}
//функция для подтверждения сделаного(проверенного) задания только для учителя 
function readyhomework(bool done, uint id ) public onlyteac {
    require(id >= 0 ,"");
    dz[user[msg.sender].class][id].done = done;
}
//функция добавления расписание уроков доступна только учителю
function addtimetable(string memory week,string memory namepredmet1,string memory namepredmet2,string memory namepredmet3 ,string memory
namepredmet4,string memory namepredmet5,string memory namepredmet6,string memory namepredmet7,string memory namepredmet8) public onlyteac  {
require(bytes(week).length > 0,"Поле день недели не может быть пустым");
timetable[user[msg.sender].class].push(Structures.timetable(timetable[user[msg.sender].class].length,week,namepredmet1,namepredmet2,namepredmet3,
namepredmet4,namepredmet5,namepredmet6,namepredmet7,namepredmet8));
}
//функция  просмотра расписание предметов
function gettimetable() public noguest view returns (Structures.timetable [] memory) {
    return(timetable[user[msg.sender].class]);
}

//функция изменения расписания
function chengtimetable(uint id,string memory week,string memory namepredmet1,string memory namepredmet2,string memory namepredmet3 ,string memory
namepredmet4,string memory namepredmet5,string memory namepredmet6,string memory namepredmet7,string memory namepredmet8) public onlyteac  {
timetable[user[msg.sender].class][id] = Structures.timetable(id,week,namepredmet1,namepredmet2,namepredmet3,
namepredmet4,namepredmet5,namepredmet6,namepredmet7,namepredmet8);
}
       
}