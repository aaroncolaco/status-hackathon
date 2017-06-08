var ABI = [{ "constant": true, "inputs": [], "name": "getIncomingRequests", "outputs": [{ "name": "", "type": "uint256[]" }, { "name": "", "type": "address[]" }, { "name": "", "type": "bytes32[]" }, { "name": "", "type": "uint256[]" }, { "name": "", "type": "uint256[]" }, { "name": "", "type": "uint256[]" }, { "name": "", "type": "bytes32[]" }], "payable": false, "type": "function" }, { "constant": false, "inputs": [{ "name": "reqid", "type": "uint256" }], "name": "rejectRequest", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [{ "name": "reqid", "type": "uint256" }], "name": "acceptRequest", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [{ "name": "name", "type": "bytes32" }, { "name": "max_amount", "type": "uint256" }, { "name": "min_amount", "type": "uint256" }, { "name": "interest", "type": "bytes32" }], "name": "newLender", "outputs": [], "payable": false, "type": "function" }, { "constant": false, "inputs": [{ "name": "userId", "type": "address" }, { "name": "amount", "type": "uint256" }, { "name": "duration", "type": "uint256" }, { "name": "purpose", "type": "bytes32" }], "name": "borrowRequest", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "getSender", "outputs": [{ "name": "", "type": "address" }], "payable": false, "type": "function" }, { "constant": true, "inputs": [{ "name": "amount", "type": "uint256" }], "name": "getAllLenders", "outputs": [{ "name": "", "type": "address[]" }, { "name": "", "type": "bytes32[]" }, { "name": "", "type": "uint256[]" }, { "name": "", "type": "uint256[]" }, { "name": "", "type": "bytes32[]" }], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "getBorrowerName", "outputs": [{ "name": "", "type": "bytes32" }], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "getlenderName", "outputs": [{ "name": "", "type": "bytes32" }], "payable": false, "type": "function" }, { "constant": false, "inputs": [{ "name": "name", "type": "bytes32" }], "name": "newBorrower", "outputs": [], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "checkAccountExists", "outputs": [{ "name": "", "type": "bool" }], "payable": false, "type": "function" }, { "anonymous": false, "inputs": [{ "indexed": true, "name": "reqId", "type": "uint256" }, { "indexed": true, "name": "from", "type": "address" }, { "indexed": true, "name": "to", "type": "address" }], "name": "RequestMoney", "type": "event" }, { "anonymous": false, "inputs": [{ "indexed": true, "name": "reqId", "type": "uint256" }, { "indexed": true, "name": "from", "type": "address" }, { "indexed": true, "name": "to", "type": "address" }], "name": "AcceptRequest", "type": "event" }, { "anonymous": false, "inputs": [{ "indexed": true, "name": "reqid", "type": "uint256" }, { "indexed": true, "name": "from", "type": "address" }, { "indexed": true, "name": "to", "type": "address" }], "name": "RejectRequest", "type": "event" }, { "anonymous": false, "inputs": [{ "indexed": false, "name": "reqId", "type": "uint256" }, { "indexed": false, "name": "from", "type": "address" }, { "indexed": false, "name": "data", "type": "bytes32" }], "name": "Testing", "type": "event" }];
var contractAddress = '0xca00d41a8f7325b058f2a77291d9687b5cdab34c';

var contractInstance = web3.eth.contract(ABI).at(contractAddress);
var listOfLenders = ["Hello", "Goodbye"];


// Borrow
status.command({
    name: "borrow",
    title: "Borrow",
    description: "Borrow - specify amount, duration, purpose, lenderId",
    color: "#CCCCCC",
    params: [{
        name: "amount",
        type: status.types.NUMBER
    },
    {
        name: "duration",
        type: status.types.NUMBER
    },
    {
        name: "purpose",
        type: status.types.TEXT
    },
    {
        name: "lenderId",
        type: status.types.TEXT,
        suggestions: lenderSuggestions
    }],
    preview: function (params) {
        var text = status.components.text(
            {
                style: {
                    marginTop: 5,
                    marginHorizontal: 0,
                    fontSize: 14,
                    fontFamily: "font",
                    color: "black"
                }
            }, borrowAmount(params));

        return { markup: status.components.view({}, [text]) };
    }
});

function borrowAmount(params) {
    return 'Lender: ' + params.lenderId;
    // return contractInstance.getAllLenders(params.amount, { from: web3.eth.accounts[0] });
}

function lenderSuggestions() {
    var suggestions = listOfLenders.map(function (entry) {
        return status.components.touchable(
            { onPress: status.components.dispatch([status.events.SET_COMMAND_ARGUMENT, [3, entry]]) },
            status.components.view(
                suggestionsContainerStyle,
                [status.components.view(
                    suggestionSubContainerStyle,
                    [
                        status.components.text(
                            { style: valueStyle },
                            entry
                        )
                    ]
                )]
            )
        );
    });

    // Let's wrap those two touchable buttons in a scrollView
    var view = status.components.scrollView(
        suggestionsContainerStyle(2),
        suggestions
    );

    // Give back the whole thing inside an object.
    return { markup: view };
}



// List lenders
status.command({
    name: "listLenders",
    title: "ListLenders",
    description: "List all valid lenders for an amount",
    color: "#CCCCCC",
    params: [{
        name: "amount",
        type: status.types.NUMBER
    }],
    preview: function (params) {
        var text = status.components.text(
            {
                style: {
                    marginTop: 5,
                    marginHorizontal: 0,
                    fontSize: 14,
                    fontFamily: "font",
                    color: "black"
                }
            }, getLenders(params));

        return { markup: status.components.view({}, [text]) };
    }
});

function getLenders(params) {
    var returnString = '';
    var lenderArray = contractInstance.getAllLenders(params.amount, { from: web3.eth.accounts[0] });
    lenderArray = transposeArray(lenderArray);

    returnString = web3.toAscii(lenderArray[0][1]).replace(/\u0000/g,'') + ', ' + lenderArray[0][2] + ', ' + lenderArray[0][3] + ', ' + web3.toAscii(lenderArray[0][4]);
    return returnString;
}


// Register as Borrower
status.command({
    name: "registerAsBorrower",
    title: "RegisterBorrower",
    description: "Register as a Borrower",
    color: "#CCCCCC",
    params: [{
        name: "borrowerName",
        type: status.types.TEXT
    }],
    preview: function (params) {
        var text = status.components.text(
            {
                style: {
                    marginTop: 5,
                    marginHorizontal: 0,
                    fontSize: 14,
                    fontFamily: "font",
                    color: "black"
                }
            }, registerAsBorrower(params));

        return { markup: status.components.view({}, [text]) };
    }
});

function registerAsBorrower(params) {
    return contractInstance.newBorrower.sendTransaction(params.borrowerName, { from: web3.eth.accounts[0] });
}

// Register as Lender
status.command({
    name: "registerAsLender",
    title: "RegisterLender",
    description: "Register as a Lender",
    color: "#CCCCCC",
    params: [{
        name: "lenderName",
        type: status.types.TEXT
    },
    {
        name: "minAmount",
        type: status.types.NUMBER
    },
    {
        name: "maxAmount",
        type: status.types.NUMBER
    },
    {
        name: "interestRate",
        type: status.types.TEXT
    }],
    preview: function (params) {
        var text = status.components.text(
            {
                style: {
                    marginTop: 5,
                    marginHorizontal: 0,
                    fontSize: 14,
                    fontFamily: "font",
                    color: "black"
                }
            }, registerAsLender(params));

        return { markup: status.components.view({}, [text]) };
    }
});

function registerAsLender(params) {
    return contractInstance.newLender.sendTransaction(params.lenderName, parseInt(params.minAmount), parseInt(params.maxAmount), params.interestRate, { from: web3.eth.accounts[0] });
}


// load app
status.addListener("init", function (params, context) {
    var result = {
        err: null,
        data: null,
        messages: []
    };
    try {
        result["text-message"] = 'Hi there!';
    } catch (e) {
        result.err = e;
    }
    return result;
});

// unknown text
status.addListener("on-message-send", function (params, context) {
    var result = {
        err: null,
        data: null,
        messages: []
    };
    try {
        result["text-message"] = 'Sorry, I didn\'t get that.';
    } catch (e) {
        result.err = e;
    }
    return result;
});

// helpers
function suggestionsContainerStyle(suggestionsCount) {
    return {
        marginVertical: 1,
        marginHorizontal: 0,
        keyboardShouldPersistTaps: "always",
        height: Math.min(150, (56 * suggestionsCount)),
        backgroundColor: "white",
        borderRadius: 5,
        flexGrow: 1
    };
}
var suggestionSubContainerStyle = {
    height: 56,
    borderBottomWidth: 1,
    borderBottomColor: "#0000001f"
};

function transposeArray(arr) {
    return arr[0].map(function (col, i) {
        return arr.map(function (row) {
            return row[i];
        });
    });
}

var valueStyle = {
    marginTop: 9,
    fontSize: 14,
    fontFamily: "font",
    color: "#000000de"
};