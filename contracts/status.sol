
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
    function acceptRequest(uint reqid) {
        if (reqid > totalReq && reqid <= 0) {
            throw;
        } else {
            if (request[reqid].to == msg.sender) {
                request[reqid].status = "accepted";
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
    function getIncomingRequests() constant returns(uint[]) {
        return incomingRequest[msg.sender];
    }
    // get Outgoing request function
    function getOutgoingRequests() constant returns(uint[]) {
        return outgoingRequest[msg.sender];
   }


    // get all requests
    function getAllRequestDetails(uint reqid) external constant returns(bytes32[8]) {
        bytes32[8] memory temp;
        if (request[reqid].from == msg.sender || request[reqid].to == msg.sender) {
          /*
          returns:
        address from;
        address to;
        bytes32 status;
        uint256 date;
        uint256 amount;
        uint256 duration;
        bytes32 purpose;
          */
          
            temp[0] = bytes32(request[reqid].from);
            temp[1] =bytes32(request[reqid].to); 
            temp[2] = request[reqid].status;
            temp[3] = bytes32(request[reqid].date);
            temp[5] =bytes32(request[reqid].amount);
            temp[6] = bytes32(request[reqid].duration);
            temp[7] = request[reqid].purpose;
        }
        return temp;
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
    function newLender(bytes32 name, uint256 max_amount, uint256 min_amount,bytes32 interest) {

        
       
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
    function getAllLenders(uint amount) constant returns(  bytes32[] memory ) {
              //bytes32[nos] memory temp;
              bytes32[] memory temp;
            temp = new bytes32[](userNos);
            uint  count=0;
             for (uint i = 0; i < userNos; i++) {
                 
                 if( ( lenderAccounts[userList[i]].account_type == 'lender')  && (amount <= lenderAccounts[userList[i]].max_amount)  && (amount >= lenderAccounts[userList[i]].min_amount)   )
                  {
                  temp[i]=bytes32(userList[i]);
                  count++;
                  }
                 
             }
             
                
               
               
              return temp ;
    }
    
    // get lender Details
    function getInterest(address addr)constant returns (bytes32[2] memory){
         bytes32[2] memory temp;
         
         temp[0]= lenderAccounts[addr].name;
         temp[1]=lenderAccounts[addr].interest;
         return temp;
            
    }
    
    // test function
    function getSender() constant returns(address) {
        return msg.sender;
    }

}

// Digital locker contract
contract DigitalLocker is  AccountContract, RequestContract {

    address owner = msg.sender;
    // reset data function
    // function resetData() {

    //     delete accounts[msg.sender];
  
    //     for (uint j = 0; j < totalReq; j++)
    //         delete request[j];
    //     delete totalReq;
    // }


}
