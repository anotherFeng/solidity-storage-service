pragma solidity ^0.5.0;

contract StorageService {

    struct Record {
        uint256 id;
        address owner;
        string ipfsCid;
        uint256 index;
    }

    event RecordEvent (
        uint256 id,
        address owner,
        string ipfsCid,
        uint256 index,
        string eventType
    );



    mapping(uint256 => Record) private recordMapping;

    //An unordered index of the items that are active.
    uint256[] private recordIndex;

    //Don't want to reuse ids so just keep counting forever.
    uint256 private nextId;


    function create(string calldata _ipfsCid) external returns (uint256 id) {
        
        nextId++;

        Record memory record = Record({
            id : nextId,
            owner: msg.sender,
            ipfsCid : _ipfsCid,
            index: recordIndex.length
        });

        //Put item in mapping
        recordMapping[record.id] = record;


        //Put id in index
        recordIndex.push(record.id);


        emit RecordEvent(
            recordMapping[record.id].id,
            recordMapping[record.id].owner,
            recordMapping[record.id].ipfsCid,
            recordMapping[record.id].index,
            "NEW"
        );


        return recordMapping[id].id;
    }

    function read(uint256 _id) public view returns (address owner, string memory ipfsCid, uint256 index ) {

        Record storage record = recordMapping[_id];

        return (record.owner, record.ipfsCid, record.index);
    }

    function update(uint256 _id, string calldata _ipfsCid) external {

        if (keccak256(bytes(recordMapping[_id].ipfsCid)) != keccak256(bytes(_ipfsCid))) {
            recordMapping[_id].ipfsCid = _ipfsCid;

            emit RecordEvent(
                recordMapping[_id].id,
                recordMapping[_id].owner,
                recordMapping[_id].ipfsCid,
                recordMapping[_id].index,
                "UPDATE"
            );   
        }
    }


    //Paging functionality
    function count() external view returns (uint256 theCount) {
        return recordIndex.length;
    }

    function readByIndex(uint256 _index) external view returns (address owner, string memory ipfsCid, uint256 index) {
        
        require(_index < recordIndex.length, "No item at index");

        uint256 idAtIndex = recordIndex[_index];

        require(idAtIndex >= 0, "Invalid id at index");

        return read(idAtIndex);
    }






}

