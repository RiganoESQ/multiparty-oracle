pragma solidity ^0.4.24;

import "../ownership/Ownable.sol";

contract MPOStorage is Ownable{



	mapping(uint256 => uint256) queryStatus;// Threshold reached, do not accept any more responses
	mapping(uint256 => mapping(string => uint256) ) responseTally; // Tally of each response.
	mapping(uint256 => uint256) mpoToClientId;

	uint256 threshold;
	address[] responders;

	// implements Client1
	address client;

	uint256 clientQueryId; 


	//Set Methods/Mutators
	function setThreshold(uint256 _threshold) external onlyOwner {
		threshold = _threshold;
	}

	

	function setClientQueryId(uint256 _clientQueryId) external onlyOwner {
		clientQueryId = _clientQueryId;
	}
	function setClientQueryId(uint256 mpoId, uint256 _clientQueryId) external onlyOwner {
		mpoToClientId[mpoId] = _clientQueryId;
	}
 
	function setResponders(address[] parties) external onlyOwner {
		for(uint256 i=0;i<parties.length;i++){
			responders.push(parties[i]);
		}
	}

	function setQueryStatus(uint queryId, uint status) external onlyOwner {
		queryStatus[queryId]=status;
	}

	function addResponse(uint256 queryId, string response, address party) external onlyOwner {
		responseTally[queryId][response]++;
	}

	//Get Methods/Accessors
	
	function getThreshold() external view returns(uint) { 
		return threshold;
	}
	
	function getTally(uint256 queryId, string response)external view returns(uint256){
		return responseTally[queryId][response];
	}

	function getClientQueryId() external view returns(uint256){
		return clientQueryId;
	}
	function getClientQueryId(uint256 mpoId) external view returns(uint256){
		return mpoToClientId[mpoId];
	}

	function getQueryStatus(uint256 queryId) external view returns(uint256){
		return queryStatus[queryId];
	}

	function getNumResponders() external view returns (uint) {
		return responders.length;
	}

	function getResponderAddress(uint index) external view returns(address){
		return responders[index];
	}
}
