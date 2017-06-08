
pragma solidity ^0.4.2;

contract RequestContract { // Request Contract
    struct Request { // Request structure
        uint reqId;
        address from;
        address to;
        bytes32 status;
        uint256 date;
        uint256 amount;
        uint256 duration;
        bytes32 purpose;
         }
    uint totalReq = 0;
    // map of Requests
    mapping(uint => Request) request;
    mapping(address => uint[]) incomingRequest;
    mapping(address => uint[]) outgoingRequest;
   

    //Events for requests
    event RequestMoney( uint indexed reqId,address indexed from, address indexed to);
    event AcceptRequest(uint indexed reqId, address indexed from, address indexed to);
    event RejectRequest(uint indexed reqid, address indexed from, address indexed to);

    function borrowRequest(address userId,uint256 amount, uint256 duration, bytes32 purpose) {

        totalReq++;
        request[totalReq] = Request({
            reqId: totalReq,
            from:msg.sender,
            to: userId,
            status: "requested",
            date: now,
            amount: amount ,
            duration: duration,
            purpose: purpose
          
          
        });

        outgoingRequest[msg.sender].push(totalReq);
        incomingRequest[userId].push(totalReq);
        RequestMoney(totalReq,userId, msg.sender); // request event


    }
    
    // accept request function
    function acceptRequest(uint reqid) payable {
        if (reqid > totalReq || reqid <= 0 || msg.value != request[reqid].amount  ) {
            throw;
        } else {
            if (request[reqid].to == msg.sender) {
                request[reqid].status = "accepted";
                  request[reqid].from.send(msg.value);
                
                }
        }
        AcceptRequest(reqid, msg.sender, request[reqid].from); // accept event
    }
   
    // reject request function
    function rejectRequest(uint reqid) {
        if (reqid > totalReq && reqid <= 0) {
            throw;
        } else {
            if (request[reqid].to == msg.sender) {
                request[reqid].status = "rejected";
                          }
        }
        RejectRequest(reqid, msg.sender, request[reqid].from); // reject event
    }
    
    // get incoming request function
    function getIncomingRequests() constant returns(uint[]  memory, address[]  memory,  bytes32[]  memory, uint256[]  memory, uint256[]  memory, uint256[]  memory , bytes32[]  memory) {
       
       uint[] memory id;
       address[]  memory from;
       bytes32[] memory status;
       uint256[]  memory date;
       uint256[] memory  amount;
       uint256[] memory duration;
       bytes32[] memory purpose;
       
       id = new uint[](totalReq);
       from = new address[](totalReq);
       status = new bytes32[](totalReq);
       date = new uint256[](totalReq);
       amount = new uint256[](totalReq);
       duration = new uint256[](totalReq);
       purpose = new bytes32[](totalReq);
        for(uint i=0; i< incomingRequest[msg.sender].length;i++) {
            uint  reqId = incomingRequest[msg.sender][i];
            id[i] = request[reqId].reqId;
            from[i] = request[reqId].from;
            status[i] = request[reqId].status;
            date[i] = request[reqId].date; 
            amount[i] = request[reqId].amount;
            purpose[i] = request[reqId].purpose;
         }
         return (id,from,status,date,amount,duration,purpose);
    }
    

}
contract AccountContract { // Account contract 
    struct LenderAccount //  LenderAccount structure
    {
        bytes32 name;
        uint256 max_amount;
        uint256 min_amount;
        bytes32 interest;
        bytes32 account_type;
    }

    // map of accounts
    mapping(address => LenderAccount) lenderAccounts;
    
      struct BorrowerAccount //  BorrowerAccount structure
    {
        bytes32 name;
        bytes32 account_type;
    }

    // map of accounts
    mapping(address => BorrowerAccount) borrowerAccounts;
    
     event Testing( uint  reqId,address  from, bytes32  data);
    
    address[] userList;
      uint userNos;
     
     //constructor
    function AccountContract()
    {
        userNos=0;
        userList=new address[](10);
    }
  
  //only lender   
    function checkAccountExists() constant returns(bool) {
        if (lenderAccounts[msg.sender].name == "") {
            return false;
        } else {
            return true;
        }
    }
    

    // new Lender account function
    function newLender(bytes32 name, uint256 min_amount,uint256 max_amount,bytes32 interest) {

        
       
            lenderAccounts[msg.sender].name = name;
            lenderAccounts[msg.sender].max_amount = max_amount;
            lenderAccounts[msg.sender].min_amount = min_amount;
            lenderAccounts[msg.sender].interest=interest;
            lenderAccounts[msg.sender].account_type = "lender";
           
         
              
               Testing(1,msg.sender,"done");
             userList[userNos]=msg.sender;
            userNos++;
            
            
       

    }
    
      // new Borrower account function
    function newBorrower(bytes32 name) {


            borrowerAccounts[msg.sender].name = name;
            borrowerAccounts[msg.sender].account_type = "borrower";
           
            // userList[userNos]=msg.sender;
            // userNos++;
      

    }

    // get lender name function
    function getlenderName() constant returns(bytes32) {
        return lenderAccounts[msg.sender].name;
    }
     // get Borrower name function
    function getBorrowerName() constant returns(bytes32) {
        return borrowerAccounts[msg.sender].name;
    }
    
  
    // borrow function return list of lenders
    function getAllLenders(uint amount) constant returns( address[] memory, bytes32[] memory, uint256[] memory, uint256[] memory, bytes32[] memory) {
               address[] memory addr;
               bytes32[] memory name;
               uint256[] memory max;
               uint256[] memory min;
               bytes32[] memory interest;
            addr = new address[](userNos);
            name = new bytes32[](userNos);
            max = new uint256[](userNos);
            min = new uint256[](userNos);
            interest = new bytes32[](userNos);
            uint  count=0;
             for (uint i = 0; i < userNos; i++) {
                 
                 if( ( lenderAccounts[userList[i]].account_type == 'lender')  && (amount <= lenderAccounts[userList[i]].max_amount)  && (amount >= lenderAccounts[userList[i]].min_amount)   )
                  {
                   addr[i]=userList[i];
                   address temp = userList[i];
                     name[count]= lenderAccounts[temp].name;
                       min[count]= lenderAccounts[temp].min_amount;
                      max[count]= lenderAccounts[temp].max_amount;
                      interest[count]= lenderAccounts[temp].interest;
                  count++;
                  }
                 
             }
   
              return (addr,name,max,min,interest);
    }

    // test function
    function getSender() constant returns(address) {
        return msg.sender;
    }

}

// Digital locker contract
contract microLending is  AccountContract, RequestContract {

    address owner = msg.sender;
    // reset data function
    // function resetData() {

    //     delete accounts[msg.sender];
  
    //     for (uint j = 0; j < totalReq; j++)
    //         delete request[j];
    //     delete totalReq;
    // }


}
