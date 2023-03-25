// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract LandRegistration {
    // to store lands detail
    struct LandDetails {
        uint256 landId;
        uint256 area;
        string city;
        string pradesh;
        uint256 propertyId;
        string document;
    }

    // To store users deails
    struct User {
        address id;
        string name;
        uint256 age;
        string city;
        string citizenshipNumber;
        string email;
        string document;
        uint256[] landsOwned;
        bool exist;
    }

    // to store land Inspector details
    struct LandInspector{
        uint256 id;
        string name;
        uint256 age;
        string designation;
    }
    
    // to store land request details
    struct LandRequest{
        uint256 requestId;
        address buyerAddress;
        address sellerAddress;
        uint256 landId;
    }

    // key value pairs
    mapping(uint256 => LandDetails) public lands;
    mapping(uint256 => LandInspector) public Inspectors;
    mapping(address=>User) public usersMapping;
    mapping(uint256=> address) public LandOwner;
    mapping(uint256=>LandRequest) public RequestMapping;

    mapping(address => LandDetails[]) public landOwners;


    mapping(address=>bool) public UserVerification;
    mapping(address=>bool) public UserRejection;
    mapping(uint256=>bool) public LandVerification;
    mapping(address=>bool) public RegisteredUserMapping;
    mapping(address=>bool) public RegisteredAddressMapping;

    mapping(uint256=>bool) public RequestStatus;
    mapping(uint256=>bool) public TransferStatus;
    mapping(uint256=>bool) public RequestedLand;
    mapping(uint256=>bool) public PaymentReceived;


    address public Land_Inspector;// address of land registrator
    address[] public users;

    uint256 public landCount;
    uint256 public usersCount;
    uint public requestsCount;

    // events
    event Registration(address _registrationId);
    event AddingLand(uint256 indexed _landId);
    event LandRequested(address _userAddress);
    event requestApproved(address _userAddress);
    event Verified(address _id);
    event Rejected(address _id);


    // to define land registrator
    constructor() public{
        Land_Inspector= msg.sender;
        addLandInspector("Inspector", 45, "admin");
    }

    // function to add land inspector
    function addLandInspector(string memory _name, uint256 age, string memory designation)private{
        Inspectors[0]=LandInspector(1,_name,age,designation);
    }

    // to view land registrator details
    function viewLandRegistrator() public view returns (address,uint256,string memory,uint256,string memory){
        return (
            Land_Inspector,
            Inspectors[0].id,
            Inspectors[0].name,
            Inspectors[0].age,
            Inspectors[0].designation
        );

    }

    // to verify land inspector
    function isLandInspector(address _id) public view returns (bool){
        if(Land_Inspector == _id){
            return true;
        }
        else{
            return false;
        }
    }

        // function to add or register user
    function addUser( string memory _name, uint256 _age, string memory _city, string memory _citizenshipNumber, string memory _email, string memory _document) public{
        // require that buyer is not already registered
        require(!RegisteredAddressMapping[msg.sender]);

        // make user registered
        RegisteredAddressMapping[msg.sender]=true;
        RegisteredUserMapping[msg.sender]= true;
        usersCount++;
        usersMapping[msg.sender] = User(msg.sender, _name, _age, _city, _citizenshipNumber, _email, _document, new uint256[](0), true);
        users.push(msg.sender);
        emit Registration(msg.sender);
    }

    // function to update the user information
    function updateUser(string memory _name, uint256 _age, string memory _city, string memory _citizenshipNumber, string memory _email, string memory _document) public{
        // the user should be already registered
        require(RegisteredAddressMapping[msg.sender] && (usersMapping[msg.sender].id == msg.sender));
        usersMapping[msg.sender].name=_name;
        usersMapping[msg.sender].age=_age;
        usersMapping[msg.sender].city=_city;
        usersMapping[msg.sender].citizenshipNumber=_citizenshipNumber;
        usersMapping[msg.sender].email=_email;
        usersMapping[msg.sender].document=_document;
    }


    // function to view user
    function getUser() public view returns(address[] memory){
        return (users);
    }

    // function to get users details
    function getUserDetails(address i) public view returns(string memory, uint256, string memory, string memory, string memory, string memory, bool){
        return(
            usersMapping[i].name,
               usersMapping[i].age,
               usersMapping[i].city,
               usersMapping[i].citizenshipNumber,
               usersMapping[i].email,
               usersMapping[i].document,
            //    usersMapping[i].landsOwned,
               usersMapping[i].exist
               );
    }

    // function to get current user details
    function getCurrentUserDetails() public view returns(string memory, uint256, string memory, string memory, string memory, string memory, uint256[] memory,bool){
        return(
            usersMapping[msg.sender].name,
               usersMapping[msg.sender].age,
               usersMapping[msg.sender].city,
               usersMapping[msg.sender].citizenshipNumber,
               usersMapping[msg.sender].email,
               usersMapping[msg.sender].document,
               usersMapping[msg.sender].landsOwned,
               usersMapping[msg.sender].exist
               );
    }

 

    // function to tell if user or not
    function isUser(address _id) public view returns (bool){
        if(RegisteredUserMapping[_id]){
            return true;
        }
    }

    function isVerified(address _id) public view returns (bool){
        if(UserVerification[_id]){
            return true;
        }
    }

    function isRejected(address id) public view returns(bool){
        if(UserRejection[id]){
            return true;
        }
    }

    // to verify user
    function verifyUser(address _userAddress) public{
        require(isLandInspector(msg.sender));

        UserVerification[_userAddress]= true;

        // event emit for verification
        emit Verified(_userAddress);
    }

    // function to reject user
    function rejectUser(address _userAddress) public{
        require(isLandInspector(msg.sender));
        UserRejection[_userAddress]=true;
        emit Rejected(_userAddress);
    }

    function isRegistered(address i) public view returns(bool){
        if(RegisteredUserMapping[i]){
            return true;
        }
    }

    // to add land
    function addLand(uint256 _area, string memory _city, string memory _pradesh, uint256 _propertyId, string memory _document) public {
        require((isUser(msg.sender)) && (isVerified(msg.sender)));
        // lands[_landId] = LandDetails(_landId, _area, _city, _pradesh, _propertyId, _document);
        landCount++;
        lands[landCount] = LandDetails(landCount, _area, _city, _pradesh, _propertyId, _document);
        LandOwner[landCount]=msg.sender;

        //to add land to particular user
        // usersMapping[msg.sender].landsOwned.push(_landId);
        // landOwners[msg.sender].push(lands[_landId]);
         landOwners[msg.sender].push(lands[landCount]);
         emit AddingLand(landCount);


    }

            // function to get lands of the current user
    function getLands() public view returns (LandDetails[] memory) {
        return landOwners[msg.sender];
    }

    function getLandOwner(uint id) public view returns (address) {
        return LandOwner[id];
    }

    // function to get land details from landId
    function getLandDetails(uint256 _landId) public view returns (uint256, uint256, string memory, string memory, uint256, string memory) {
        // require(_landId > 0 && _landId <= landCount, "Invalid land ID");
        return (
            lands[_landId].landId,
            lands[_landId].area,
            lands[_landId].city,
            lands[_landId].pradesh,
            lands[_landId].propertyId,
            lands[_landId].document
        );
    }

    // to verify the land details by land inspector
    function verifyLand(uint256 _landId) public{
        require(isLandInspector(msg.sender));
        LandVerification[_landId]= true;
    }

    // to check if land is verified or not
    function isLandVerified(uint256 _id) public view returns(bool){
        if(LandVerification[_id]){
            return true;
        }
    }

    // to view lands of the certain user
    // function viewLands(address i) public view returns(uint256,uint256,string memory, uint256, string memory){
    //     return(
            

    //     );
    // }





    // to return lands count
    function getLandsCount() public view returns(uint256){
        return landCount;
    }

    // to return user count
    function getUsersCount() public view returns(uint256){
        return usersCount;
    }


    // function to request land
    function requestLand(address _sellerAddress,uint256 _landId) public{
        require(isUser(msg.sender) && isVerified(msg.sender));

        requestsCount++;
        RequestMapping[requestsCount]= LandRequest(requestsCount,msg.sender,_sellerAddress,_landId);
        RequestStatus[requestsCount]=false;
        RequestedLand[requestsCount]=true;

        //additional
        TransferStatus[requestsCount]=false;
        emit LandRequested(_sellerAddress);

    }

    function getRequestsCount() public view returns (uint) {
        return requestsCount;
    }

    // function to get all request details
    function requestDetails(uint256 i) public view returns(address,address,uint256,bool,bool){
        return(RequestMapping[i].sellerAddress, RequestMapping[i].buyerAddress, RequestMapping[i].landId, RequestStatus[i], TransferStatus[i]);
    }

    function isRequested(uint256 id) public view returns(bool){
        if(RequestedLand[id]){
            return true;
        }
    }

    function isApproved(uint256 id) public view returns(bool){
        if(RequestStatus[id]){
            return true;
        }
    }


    // fucnion to approve request
    function approveRequest(uint256 _requestId)public{
        require((isUser(msg.sender)) && (isVerified(msg.sender)));
        RequestStatus[_requestId]=true;
    }

    function LandOwnershipTransfer(uint256 land_id, address newOwner)public {
        require(isLandInspector(msg.sender));
        address previousOwner= LandOwner[land_id];
        LandOwner[land_id]= newOwner;
        landOwners[newOwner].push(lands[land_id]);
    

        // remove land from previous user
        //landOwners[previousOwner].remove(lands[land_id]);
    }

        // fucnion to approve request
    function checkTransfer(uint256 _requestId)public{
        require(isLandInspector(msg.sender));
        TransferStatus[_requestId]=true;
    }

    function isPaid(uint256 _landId) public view returns(bool){
        if(PaymentReceived[_landId]){
            return true;
        }
    }

    function payment(address payable _receiver, uint256 _landId) public payable{
        PaymentReceived[_landId]=true;
        _receiver.transfer(msg.value);
    }


}
