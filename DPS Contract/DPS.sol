pragma solidity ^ 0.6.12;
pragma experimental ABIEncoderV2;
//Разработчики решения Корнеев Денис и Варламов Дамир ГАПОУ "СГК".2021
//266266315 TIME
//Библиотека со всеми структурами
library structures {
    //указываю все роли в рамках смарт контракта
    enum roles {
        guest,//гость
        user,//пользователь
        driver,//водитель
        DPS,//сотрудник ДПС
        admin,//Админ
        compani//компания
    }
    //enum companirole{
   //     compani
   // }
    //структура пользователя решением
    struct users {
        string  login ;//логин
        string password;//пароль
        string FIO;//ФИО Фамилия Имя Отчество
        roles role;//роль в сиситеме
    }
    //структура подтвержденного водителя (имеет больше прав чем обычный user)
    struct driver {
        string FIO;//ФИО
        VU vu;//взаимствование данных с другой структуры
        uint stach;//стаж водителя 
        uint dtp;//количество дтп с участием водителя
        Fine fine;//взаимствование данных с другой структуры
        int straxov;//страховой взнос 
        int balance ;//баланс водителя в системе (монетки)
    }
    //структура Водительского удостоверения 
    struct VU{              
    uint id;//id для удобства работы 
       string  number;//номер водительского удостоверениЯ
       uint yerspolch;//год получения ву
       Srock srock;//взаимствование данных с другой структуры(разделение на день месяц год )
       string FIO;//ФИО Фамилия Имя Отчество
       bool A;//категория ву А
       bool B;// категория ву В
       bool C;//категория ву С
       address add;//аддресс водителя в системе
    }
    //структра разделения времени
    struct Srock {
        uint day ;//день
        uint month;//месяц
        uint yers;//год
    }
    //структра со штрафами
    struct Fine {
        uint id;//id для удобства использования
        uint kolvo; // количество штрафов ..пересмотреть
        
    }
    //структра ТС -транспортного средства 
    struct car {
        bool A;//категория А
        bool B;//категория В
        bool C;//категория С
        uint cost;//рыночная стоимость машины
        uint srock;//срок эксплотации ТС
    }
    //структура компании
    struct compani {
        string name;//имя
        int balance ;//баланс в системе  (монетки)
        int dolg;
        address add;
        roles companirole;
    }
    //структура ДТП 
    struct DTP{
        uint id;//id для удобсва использования 
        string number;//номер ву водителя который стал участником ДТП
        string datatime;//время когда было совершено ДТП
    }
    //сtруктура штрафов дополнительная для сотрудников ДПС и не только
    struct Finedps{
        uint id;//id  для удобсва
        string number;//номер ву
         string datatimestr;//веремя когда было сщвершено право нарушение 
        uint datatime;//времяв unix для подсчетов
    }
    struct Straxsluch{
        uint id;//id  для удобсва
        string datatime;//время выплаты
        uint cost;//количетво  выплаты 
    }
}
//начало смарт-контракта
contract Main {
    //дополнительная переменная для отслеживания времени
    uint time;//вспомагательная переменная
    Main3 main3;
    Main2 main2;
    constructor (address add)public {
       time = block.timestamp;// запись переменной 
      
       user[add] =structures.users("123","123","123",structures.roles.admin);
       
    }
  //маппинг (некое хранилище данных приводит соответствие под адресом пользователя в системе ) пользователя
  mapping(address=>structures.users)user;
  //маппинг (некое хранилище данных приводит соответствие под адресом пользователя в системе ) водителя
  mapping(address=>structures.driver)driver;
  //маппинг (некое хранилище данных приводит соответствие под адресом пользователя в системе ) ТС
  mapping(address=>structures.car)car;
   //маппинг (некое хранилище данных которое приводит соответствие ) приводит соответствие номера  адреса к номеру ВУ
  mapping(address=>string)infonumber;
  //маппинг (некое хранилище данных приводит соответствие под номером ву пользователя в системе ) пользователя
  mapping(string=>structures.Finedps [])finemap;

  //маппинг (некое хранилище данных которое приводит  соответствие ) хранит игвормации о выплате страховки
  mapping(address=>structures.Straxsluch [])strxsl;
 //масиив ВУ
  structures.VU [] vu;
  
 //модификатор  для удобсва и оптимизации
    //   modifier onlycontract {
    //  require(address(main3) == msg.sender || address(main2) == msg.sender,"Ошибка это не адрес контракта");
    //  _;
    //  }
 
//  модификатор  для удобсва и оптимизации
  modifier  noguest{
      require(user[msg.sender].role != structures.roles.guest,"Вы не зарегистрированны");//проверка на зарегистрированного пользователя
      _;
  }
  //модификатор  для удобсва и оптимизации
   modifier  onlyadmin{
      require(user[msg.sender].role == structures.roles.admin,"Вы не являетесь админом");//проверка на роль админа
      _;
  }
  //модификатор  для удобсва и оптимизации
  modifier  onlyDPS{
      require(user[msg.sender].role == structures.roles.DPS,"вы не сотрудник ДПС");//проверка на роль ДПС
      _;
  }
  //модификатор  для удобсва и оптимизации
  modifier  onlydriverUp{
      require(user[msg.sender].role != structures.roles.guest && user[msg.sender].role !=structures.roles.user,"Ошибка  вы не водитель");//проверка на роль (только водитель и выше него)
      _;
  }
    //функция регистрации
    function reg(string memory login,string memory password,string memory FIO)public {
        require(user[msg.sender].role == structures.roles.guest,"вы уже зарегистрированны");//проверка на зарегистрированного пользователя
        require(bytes(login).length >=3,"Поле логин должно быть более 3 символов");//проверка на длину логина
        require(bytes(password).length >=3,"пароль должен быть более 3 символов");//проверка на длину пароля 
        require(bytes(FIO).length >0,"Поле ФИо не может быть пустым");//проверка на длину ФИО
        user[msg.sender] = structures.users(login,password,FIO,structures.roles.user);//запись данных пользователя 
    }
    //функция авторизации
    function aut(string memory login ,string memory password)public view  noguest  {
         require(bytes(login).length >=3,"Поле логин должно быть более 3 символов");//проверка на длину логина
        require(bytes(password).length >=3,"пароль должен быть более 3 символов");//проверка на длину пароля
        require(keccak256(bytes(user[msg.sender].login)) == keccak256(bytes(login)),"Не верный логин");//проверка соответствиф введенного логина от записанного в системе 
        require(keccak256(bytes(user[msg.sender].password)) == keccak256(bytes(password)),"Не верный пароль");//проверка соответствиф введенного пароль от записанного в системе 
    }
   
    //функция добавления сотрудника ДПС доступна только админу
    function addDPS (address add) public onlyadmin {
        require(user[add].role != structures.roles.guest,"Адресс не зарегистрирован");//проверка на то что пользователь которого хотят сдеелать сотрудников ДПС зарегистрирован
         require(add!=msg.sender,"ошибка");//проверка
        user[add].role = structures.roles.DPS;//смена роли
    }
    //Удаление сотрудника ДПС(при увольнении)
     function remuveDPS (address add) public onlyadmin {
        require(user[add].role != structures.roles.guest,"Адресс не зарегистрирован");//проверка на то что пользователь которого хотят удалить из ДПС зарегистрирован
        require(add!=msg.sender,"ошибка");//проверка
        user[add].role = structures.roles.driver;//смена роли
    }
    //функция отправки данных ву в отдел ДПС
    function addvu (string memory number,uint yerspolch,uint day,uint month,uint yers,string memory FIO ,bool A,bool B,bool C) public noguest{
        require(bytes(number).length == 3,"номер ву должен быть равен 3 символа");//проверка на длину логина
        require(bytes(FIO).length > 0,"Поле ФИО не может быть пустым");//проверка на длину пароля
        require(day > 0 , "день не может быть равен 0");//день не может быть равен 0
        require(month > 0 , "месяц не может быть равен 0");//месяц не может быть равен 0
         require(yers > 1900 , "ошибка укажите коректный год");//день не может быть равен 0
         vu.push(structures.VU(vu.length,number,yerspolch,structures.Srock(day,month,yers),FIO,A,B,C,msg.sender));//запись данных в массив для того что бы сотрудник ДПС мог поддвердить их
    }
   
   
    //функция просмотра личного кабинета
    function getlk ()public view noguest returns(structures.driver memory,structures.Finedps [] memory,structures.Straxsluch [] memory){
       return(driver[msg.sender],finemap[infonumber[msg.sender]],strxsl[msg.sender]);//возрат данных
    }
    //функция регистрации машины
    function regcar(bool A,bool B,bool C,uint cost,uint srock) public noguest returns(string memory) {
        if(driver[msg.sender].vu.A == true && A == true){//проверка нас соответствиекатегории
          car[msg.sender] = structures.car(true,false,false,cost,srock)  ;//запись данных в маппинг
        }
        else if(driver[msg.sender].vu.B == true && B == true){//проверка нас соответствиекатегории
          car[msg.sender] = structures.car(false,true,false,cost,srock)  ;//запись данных в маппинг
        }
        else if(driver[msg.sender].vu.C == true && C == true){//проверка нас соответствиекатегории
          car[msg.sender] = structures.car(false,false,true,cost,srock)  ;//запись данных в маппинг
        }
        else{
            return "Ошибка!проверьте соответствие категории";//сообщение об ошибке
        
        }
    }
    //функция продления ВУ
   function upvu() public onlydriverUp  returns(string memory){
        require(driver[msg.sender].fine.kolvo == 0,"у вас не оплачены штрафы");//
        require(driver[msg.sender].vu.srock.month<=block.timestamp-time +3,"до действия ву еще больше месяца");// && driver[msg.sender].vu.srock.day <= block.timestamp-time/5  ,"");//проверкка того что до конца лицензии остался один месяц
        driver[msg.sender].vu.srock.yers +=10;//продление ву на 10 лет
        return("Успешно");//сообщение пользователю
}
    // функция просмотра своих штрафов
     function getfine(string memory number) public view onlydriverUp returns(structures.Finedps [] memory) {
         return(finemap[number]);//вызврат данных о штрафе
     }
     //функция покупки монет доп валюты в смарт-контракте
     function buymoney() public onlydriverUp payable{
         require(msg.value >=1 ether);//требование указавыть не менее одного эфира
         driver[msg.sender].balance += int(msg.value);//зачесление средст на баланс
     }
     //функция оплаты штрафа
     function buyfine(uint id,string memory number) public onlydriverUp returns(string memory){
         require(driver[msg.sender].fine.kolvo >=1,"У вас нет штрафов");//проверка на наличие штрафов
        require(bytes(number).length == 3 ,"не коректный номмер ву"); //проверка номера в
       
        //условие при котором расчитывается скидка 
        if(block.timestamp - finemap[number][id].datatime/5 <= 5 ){
           require(driver[msg.sender].balance >= 5000000000000000000,"У вас не хватает денег");//проверка на наличие нужной суммы
           driver[msg.sender].balance -= 5000000000000000000;//списание средст 
           driver[msg.sender].fine.kolvo --;//уменешения количетва не оплаченых штрафов
        }
        //дополнительное условие 
        else if (block.timestamp - finemap[number][id].datatime/5 > 5 ){
           require(driver[msg.sender].balance >= 10000000000000000000);///проверка на наличие нужной суммы
           driver[msg.sender].balance -= 10000000000000000000;//списание средст 
           driver[msg.sender].fine.kolvo --; //уменешения количетва не оплаченых штрафов
        }
        else{
            return 'ошибка оплаты !';//сообщение пользователю в случаии ошибки
        }
     }
    
     
  
   //Впомогательная функция для связи между контрактами
     function getcontract(address add) public  view  returns(structures.users memory){
         return(user[add]);
     }
     //Впомогательная функция для связи между контрактами
      function getcontract1(address add) public  view  returns(structures.driver memory){
         return(driver[add]);
     }
     //Впомогательная функция для связи между контрактами
      function getcontract2(address add) public  view  returns(structures.car memory){
         return(car[add]);
     }
     
     // Впомогательная функция для связи между контрактами
      function getcontract5() public  view  returns(structures.VU [] memory){
        return(vu);
     }
     //Впомогательная функция для связи между контрактами
     function addcontract(address add,uint id,string memory number,string memory datatimestr,uint datatime) public   {
         finemap[number].push(structures.Finedps(id,number,datatimestr,datatime));  
         driver[add].fine.kolvo +=1;//прибавление штрафа водителю
     }
     //Впомогательная функция для связи между контрактами
     function addcontract1(address add,string memory datatimestr) public  {
          driver[add].dtp +=1;//прибавления количетва дтп за водителем
          driver[add].straxov =0; //driver.balance +=driver.straxov*10;//возмешения ушерба от страховой 
          driver[add].balance +=driver[add].straxov*10;
          strxsl[add].push(structures.Straxsluch(strxsl[add].length,datatimestr,uint(driver[add].straxov)*20));//запись данных о страховой выплате
     }
     //Впомогательная функция для связи между контрактами
     function addcontract2(address add,uint id,uint stach1) public  {
         //запись данных водителя в маппинг
        driver[add]= structures.driver(vu[id].FIO,structures.VU(id,vu[id].number,vu[id].yerspolch,structures.Srock(vu[id].srock.day,vu[id].srock.month,vu[id].srock.yers),vu[id].FIO,vu[id].A,vu[id].B,vu[id].C,add),stach1,0,structures.Fine(0,0),0,0);
        user[add].role = structures.roles.driver;//смена роли с пользователя на водителя
        infonumber[add] = vu[id].number;//вспомогательный элемент 
     }  
     //Впомогательная функция для связи между контрактами
     function addcontract3(address add,int cost)public {   
         driver[add].balance -=cost;//списание средст у водителя
         driver[add].straxov = cost;//страховой взнос
     }
   // function getaddress( Main3 add) public onlyadmin {
    // main3 = add;
//}
}
//дополнительный смарт-контракт
contract Main2 {
    Main main;//переменная с адресом контракта
    Main3 main3;//переменная с адресом контракта
    //конструктор 
    constructor(Main add,Main3 add2) public {
     main = add;//наследование главного контракта
     main3 = add2;//наследование 3 контракта 
     //main.reg(string(adduser2) ,"123","Иванов Иван Иванович");
     
    }
    //функция оформления страховки
       function addstraxov(address add) public returns(int){
      string memory name = "straxov";//вспомогательный элемент
      string memory name2 = "Bank";//вспомогательный элемент
      structures.users memory users = main.getcontract(add);//Получение данных с другого контракта
       structures.driver memory driver = main.getcontract1(add);////Получение данных с другого контракта
        structures.car memory car = main.getcontract2(add);////Получение данных с другого контракта
        structures.compani memory companistax = main3.getcontract3(name);////Получение данных с другого контракта
        structures.compani memory companibank = main3.getcontract3(name2);////Получение данных с другого контракта
      require(users.role != structures.roles.guest && users.role != structures.roles.user,"ошибка");
     require(driver.straxov == 0 ,"У вас уже есть страховка");//проверка на наличие страховки
      int eth = 1000000000000000000;//вспомогательный элемент
      //расчет по формуле
      int cost = (((int(car.cost)*eth)*eth)*(eth -(int(car.srock)*eth)/10)*100000000000000000+200000000000000000*(int(driver.fine.kolvo)*eth)+(int(driver.dtp)*eth)-200000000000000000*(int(driver.stach)*eth));
        //условие скидки
        if(driver.stach >=3 && driver.stach <6){
            int cost1=cost*5/100; //вспомогательный элемент при подсчете
            cost = cost -cost1;
        }
        else if (driver.stach >=6 && driver.stach >10){//скидочное условие
            int cost1=cost*10/100; //вспомогательный элемент при подсчете
            cost = cost -cost1;
        }
        else if(driver.stach>=10){
             int cost1=cost*15/100; //вспомогательный элемент при подсчете
            cost = cost -cost1; 
        }
        else{
            cost = cost;
        }
       // require(int(driver.balance) >= cost);//проверка на наличие нужного баланса 
       // driver.balance -= cost;//списание средст у водителя
        if (companistax.dolg > 0){
            int x = companistax.dolg-cost  ;
            if(x < 0){
                int cost1 = cost - companistax.dolg;
                companistax.balance +=cost1;
                companibank.balance = companistax.dolg;
            companistax.dolg = 0;
            }
            else{
               companistax.dolg-cost;//списани баланса у страховой
               companibank.balance +=cost;//пополнение баланса банка
            }
           
            main.addcontract3(add,cost);//отправка даных в другой контракт
        }
        return (cost);
        
         
        
    

}
 
}
//дополнительный смарт-контракт
contract Main3 {
    Main main;//переменная с адресом контракта
    uint time;//вспомогательная переменная
    constructor(Main add,address add1,address add2,string memory name1,string memory name2)public {
        main =add;//запись адреса контракта 
        time = block.timestamp;//запись вспомогельной переменной 
         compani[name1] = structures.compani("Bank",0,0,add1,structures.roles.compani);//создание первичных компании в контракте
       compani[name2] = structures.compani("strax",0,0,add2,structures.roles.compani);///создание первичных компании в контракте
    }
      //маппинг (некое хранилище данных которое приводит соответствие ) приводит соответствие номера  адреса к номеру ВУ
  mapping(address=>string)infonumber;
    //маппинг (некое хранилище данных приводит соответствие под номером ву пользователя в системе ) пользователя
  mapping(string=>structures.DTP [])dtpmap;
     //маппинг (некое хранилище данных которое приводит  соответствие ) приводит соответствие номера ву  к адресу водителя в системе
  mapping(string=>address)userinfo;
    //маппинг (некое хранилище данных которое приводит  соответствие ) 
  mapping(string=>structures.compani)compani;
   //массиив с ДТП
     structures.DTP [] dtp;
   //масиив со штрафами
  structures.Finedps []fines;
  
   
  
   //функция просмотра данных на проверку подлености 
    function getlicense(address add) public view returns(structures.VU [] memory){//+++++
         structures.users memory user = main.getcontract(add);//Получение днных с другого контракта
         structures.VU [] memory vu = main.getcontract5();//Получение днных с другого контрактаПолучение днных с другого контракта
         require(user.role == structures.roles.DPS," Вы не сотрудник ДПС");//проверка
       return(vu);//возврат днных
    }
  
   //функция подтверждения Водительского удостоверения и регистрация водителя
    function adddriverlicense(uint id,address add) public {  //+++++
         structures.users memory user = main.getcontract(add);//Получение днных с другого контракта
         structures.VU [] memory vu = main.getcontract5();///Получение днных с другого контракта
         //string memory num = infonumber[add];
         require(user.role == structures.roles.DPS," Вы не сотрудник ДПС");//проверка
        require(user.role != structures.roles.guest,"пользователь не зарегистрирован");//проверка на то что пользователь которого хотят сдеелать водителем разегистрирован
        require(add!=msg.sender,"ошибка");//проверка
        uint stach1 = block.timestamp - time/5/365;//подсчет стажа
        //условие проверка на то что итоговое число болеше 1
        if(stach1 >=1){
            stach1 +=2021;
        }
        else{
           stach1 =2021 -vu[id].yerspolch;//подсчет стажа
        }
        main.addcontract2(add,id,stach1);
       userinfo[vu[id].number] = add;//вспомогательный элемент 
        infonumber[add] = vu[id].number;//вспомогательный элемент 
        
    }
    
    //функция просмтора истории всех ДТП
     function getdtp(address add) public  view returns(structures.DTP [] memory)  {//++++
         structures.users memory user = main.getcontract(add);//Получение днных с другого контракта
         require(user.role == structures.roles.DPS," Вы не сотрудник ДПС");//проверка
         return(dtp);//возврат данных 
     }
     //функция выписывания штрафа
      function addfine(string memory number,string memory datatimestr) public  {//++++
         address add = userinfo[number];//вспомагельный элемент
          structures.users memory user = main.getcontract(add);//Получение днных с другого контракта
         require(user.role == structures.roles.DPS," Вы не сотрудник ДПС");///проверка
        require(bytes(number).length == 3 ,"не коректный номмер ву"); //проверка номера в
        address adduser = userinfo[number];//вспомагельный элемент
        fines.push(structures.Finedps(fines.length,number,datatimestr,block.timestamp));///запись данных о штрафе в масиив 
         main.addcontract(adduser,fines.length,number,datatimestr,block.timestamp);//запись данных
       
        
    
}
//функция оформления ДТП
    function addDPT(address add,string memory number,string memory datatime) public  {//++++
         structures.users memory user = main.getcontract(add);//Получение днных с другого контракта
        require(user.role == structures.roles.DPS," Вы не сотрудник ДПС");
        require(bytes(number).length == 3 ,"не коректный номмер ву");//проверка номера ву
        address adduser = userinfo[number];//вспомогательная переменная
         structures.driver memory driver =main.getcontract1(adduser);//Получение днных с другого контракта
        string memory name = "strax";//вспомогательная переменнаявспомогательная переменная
        string memory name1 = "Bank";//вспомогательная переменная
        // structures.compani memory companistax = main.getcontract3(name);
       // structures.compani memory companibank = main.getcontract3(name1);
        dtp.push(structures.DTP(dtp.length,number,datatime));//фиксирование факта ДТП
        main.addcontract1(adduser,datatime);//запись данных в другой контракт 
        dtpmap[number].push(structures.DTP(dtp.length,number,datatime));//запись данных в масиив
        if(driver.straxov >0){//проверка наличия страховки
           // driver[msg.sender].balance +=driver[msg.sender].straxov*10;//возмешения ушерба от страховой 
            if(compani[name].balance <driver.straxov*10 ){//проверка наличия денег у страховой компании
                int x =driver.straxov*10 - compani[name].balance;//вспомагельный посчет 
                compani[name].balance +=x;//пополнение баланса в долг
                compani[name].dolg +=x;//прибавление долга
                compani[name1].balance -=x;//списание баланса у кредитора
             //driver.balance +=driver.straxov*10;//возмешения ушерба от страховой 
             compani[name].balance -=driver.straxov*10;//списание средст с баланса страховой
             //driver.straxov = 0;//обнуление страховки
            }
            else{
            //driver.balance +=driver.straxov*10;//возмешения ушерба от страховой 
            compani[name].balance -=driver.straxov*10;//списание средст с баланса страховой
            // driver.straxov = 0;//обнуление страховки
            }
            
           
    }
}
function getaddresscontract()public view returns(Main) {
    return(main);
}
//функция просмтора дтп
function getlkdtp() public view returns(structures.DTP [] memory){
         string memory num = infonumber[msg.sender]; 
         return(dtpmap[num]);
     }
     //вспомогательная функция 
     function getcontract3(string memory str) public  view returns(structures.compani memory){
         return(compani[str]);
     }
        //функция просмтора личного кабинета банка
     function getlkBank() public view returns(int) {
         string memory name = "Bank";//
          require(compani[name].companirole == structures.roles.compani);
          return(compani[name].balance);//возврат данных
     }
     //функция просмтора личного кабинета страховой
     function getlkstrax() public view returns(int) {
       string memory name = "straxov";//вспомогательный элемент 
      require(compani[name].companirole == structures.roles.compani);  //требование
      return(compani[name].balance);//возврат данных
    }
    //функция покупки монет доп валюты в смарт-контракте
     function buymoneyBank() public  payable{
        string memory name2 = "Bank";////вспомогательный элемент 
         require(msg.value >=1 ether);//требование указавыть не менее одного эфира
         compani[name2].balance += int(msg.value);//зачесление средст на баланс
     }
     ////функция покупки монет доп валюты в смарт-контракте
     function buymoneystrx() public  payable{
         string memory name = "straxov";//вспомогательный элемент 
         require(msg.value >=1 ether);//требование указавыть не менее одного эфира
         compani[name].balance += int(msg.value);//зачесление средст на баланс
     }
     //функция просмотра существующих компаний в смарт-контракте
     function getcompani(string memory name)public  view returns(address add){
       return(compani[name].add);//возврат данных
    }
    
    







}