pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
library Structures {
    enum Roles {
        guest,
        owner,
        admin
    }
    struct user {
        string login;
        string password;
        uint balance;
        Roles role;
    }
    struct home {
    string username;    
     uint24 area;
     uint16 kitcenarea;
     uint24 cost;
     uint16 time;
     address users;
     uint id;
     bool isrent;//проверка админом
     bool consentuser;//согласие пользователя на сдачу дома в аренду
    }
}
contract arenda1 {
    mapping(address=>Structures.user)user;
    mapping(address=>Structures.home[])home;
    Structures.home[] arenda;
    
    modifier Noguest() 
    {
        require(user[msg.sender].role != Structures.Roles.guest,"Вы не зарегистрированы");
        _;
    }
        
    
    
    constructor(address admin1,address admin2,address admin3,address admin4,address user1,address user2)public {
       user[admin1] = Structures.user("123","123",250,Structures.Roles.admin) ;
        user[admin2] = Structures.user("123","123",250,Structures.Roles.admin) ;
         user[admin3] = Structures.user("123","123",250,Structures.Roles.admin) ;
          user[admin4] = Structures.user("123","123",250,Structures.Roles.admin) ;
           user[user1] = Structures.user("123","123",250,Structures.Roles.owner) ;
            user[user2] = Structures.user("123","123",250,Structures.Roles.owner) ;
            home[user1].push(Structures.home("аноним",45,5,10,60,user1,0,true,true));
             home[user2].push(Structures.home("аноним",90,18,20,60,user2,1,true,true));
             home[user2].push(Structures.home("аноним",200,30,50,60,user2,2,true,true));
             arenda.push(Structures.home("аноним",45,5,10,60,user1,0,true,true));
             arenda.push(Structures.home("аноним",90,18,20,60,user2,1,true,true));
             arenda.push(Structures.home("аноним",200,30,50,60,user2,2,true,true));
    }
    function regist(string memory login ,string memory password) public {
        require(user[msg.sender].role == Structures.Roles.guest,"Вы уже зарегистрированы");
         require(bytes(login).length > 0,"Логин не может быть пустым");
            require(bytes(password).length > 0,"Пароль не может быть пустым");
                user[msg.sender] = Structures.user(login,password,0,Structures.Roles.owner);
    }
    function aut(string memory login,string memory password) public view Noguest {
   require(bytes(login).length > 0,"Логин не может быть пустым");
        require(bytes(password).length > 0,"Пароль не может быть пустым");
         require(keccak256(bytes(login)) == keccak256(bytes(user[msg.sender].login)),"Неверный логин");
             require(keccak256(bytes(password))== keccak256(bytes(user[msg.sender].password)),"Неверный пароль");
    }
    
    
    function addAdmin(address add)public {
       require(user[msg.sender].role == Structures.Roles.admin,"Вы должны быть админом");
       require(user[add].role == Structures.Roles.owner,"Пользователь не зарегистрирован");
         user[add].role = Structures.Roles.admin;
    }
    function reghome (string memory username ,uint24 area , uint16 kitcenarea,uint24 cost,uint16 time) public Noguest {
        require(area>0,"это поле не может быть пустым");
        require(kitcenarea > 0 ,"это поле не может быть пустым");
        require(cost > 0 ,"это поле не может быть пустым");
        require(time > 0 ,"это поле не может быть пустым");
         home[msg.sender].push(Structures.home(username,area,kitcenarea,cost,time,msg.sender,home[msg.sender].length,false,false)); 
         arenda.push(Structures.home(username,area,kitcenarea,cost,time,msg.sender,arenda.length,false,false));
    }
    
    function lk ()public view Noguest returns(string memory login,uint balance,Structures.Roles,address addres) {
        return(user[msg.sender].login,user[msg.sender].balance,user[msg.sender].role,msg.sender);
    }
    function lkhome()public view Noguest returns(Structures.home[]memory){
        return home[msg.sender];
    }
    function rent(uint id)public Noguest {
        require(arenda[id].isrent == true && arenda[id].consentuser == true,"дом уже сдан в аренду");
        user[msg.sender].balance -= arenda[id].cost;
        user[arenda[id].users].balance += arenda[id].cost;
        arenda[id].isrent = false;
        arenda[id].consentuser = false;
        
    }    
    function addbalance (uint money) public Noguest payable{
        require(msg.value>=1 ether);
        require(money != 0);
        uint88 eth = 1000000000000000000;
        require(msg.value == (money * (eth / 100)));
        user[msg.sender].balance += money;
    }
    function control(uint id)public {
        require(user[msg.sender].role == Structures.Roles.admin,"Вы не Админ");
        arenda[id].isrent = true;
    }
    function deleteAdmin()public {
        require(user[msg.sender].role == Structures.Roles.admin,"Вы не Админ");
        user[msg.sender].role = Structures.Roles.owner;
    }
    function gethom () public view  Noguest returns(Structures.home[] memory){
    return(arenda);
    }
    function addrent (uint id)public Noguest {
      require(arenda[id].users == msg.sender," вы не являетесь собственником");
      arenda[id].consentuser = true;
    }
    function deletrent (uint id)public Noguest {
        require(arenda[id].users == msg.sender," вы не являетесь собственником");
        arenda[id].consentuser = false;
    }
    function changrent(uint id,uint24 cost,uint16 time)public Noguest{
     require(arenda[id].users == msg.sender," вы не являетесь собственником");
     arenda[id].time = time;
     arenda[id].cost = cost;
    }
    
}