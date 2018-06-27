pragma solidity ^0.4.24;

import "./MPOStorage.sol";
import "./OnChainProvider.sol";
import "./Client.sol";

import "../ERC20.sol";
import "../lifecycle/Destructible.sol";

import "../../platform/bondage/BondageInterface.sol";
import "../../platform/registry/RegistryInterface.sol";
import "../../platform/dispatch/DispatchInterface.sol";

contract MultiPartyOracle is OnChainProvider, Client1 {
  event RecievedQuery(string query, bytes32 endpoint, bytes32[] params);
  event ReceivedResponse(uint256 queryId, address responder, string response);
    //event TEST(uint res, bytes32 b, string s);

    bytes32 public spec1 = "Hello?";

    // curve 2x^2
    int[] constants = [2, 2, 0];
    uint[] parts = [0, 1000000000];
    uint[] dividers = [1]; 

    RegistryInterface registry;
    MPOStorage stor;
    address public storageAddress;
    
    // middleware function for handling queries
  function receive(uint256 id, string userQuery, bytes32 endpoint, bytes32[] endpointParams, bool onchainSubscriber) external {
        emit RecievedQuery(userQuery, endpoint, endpointParams);
        if(onchainSubscriber) {
            bytes32 hash = keccak256(endpoint);

            if(hash == keccak256(spec1)) {
                endpoint1(id, userQuery, endpointParams);
                stor.setQueryStatus(id,1);

                // query each of the responders
                for(uint i=0; i<stor.getNumResponders(); i++) {      
                  OnChainProvider(stor.getResponderAddress(i)).receive(id, userQuery, endpoint, endpointParams, true);
                }
            } 
            else {
               revert("Invalid endpoint");
            }
        }
  }
    constructor(address registryAddress, address mpoStorageAddress) public{

        registry = RegistryInterface(registryAddress);
        stor = MPOStorage(mpoStorageAddress);

        // initialize in registry
        bytes32 title = "MultiPartyOracle";

        bytes32[] memory params = new bytes32[](2);
        params[0] = "p1";

        registry.initiateProvider(12345, title, spec1, params);

        registry.initiateProviderCurve(spec1, constants, parts, dividers);
        // registry.initiateProviderCurve(spec2, constants, parts, dividers);
        // registry.initiateProviderCurve(spec3, constants, parts, dividers);
        // registry.initiateProviderCurve(spec4, constants, parts, dividers);
    }

    function setParams(address[] _responders, address _client, uint256 _threshold) public {
        //require(_threshold>0 && _threshold <= _responders.length);    
        stor.setThreshold(_threshold);
        stor.setResponders(_responders);
        //stor.setClient(_client);
    }


    // return Hello World to query-maker
    function endpoint1(uint256 id, string userQuery, bytes32[] endpointParams) internal{
        Dispatch(msg.sender).respond1(id, "Hello World");
        // stor.setQueryStatus(id,1);

        // // query each of the responders
        // for(uint i=0; i<stor.getNumResponders(); i++){      
        //   OnChainProvider(stor.getResponderAddress(i)).receive(id, userQuery, endpoint, endpointParams);
        // }
    }

    function callback(uint256 queryId, string response) external {
        //require(stor.getAddressStatus(msg.sender) && !stor.onlyOneResponse(queryId, msg.sender) && stor.getQueryStatus(queryId) == 1);

        stor.addResponse(queryId, response, msg.sender);
        emit ReceivedResponse(queryId, msg.sender, response);
    
        if(stor.getTally(queryId, response) >= stor.getThreshold()) {
            stor.setQueryStatus(queryId, 2);
            //endpoint1(queryId, )
            Dispatch(msg.sender).respond1(queryId, response);
        }
  }

}

// contract MultiPartyOracle is OnChainProvider, Destructible, Client1 {

//   event ReceivedQuery(string query, bytes32 endpoint, bytes32[] params);

//   event ReceivedResponse(uint256 queryId, address responder, string response);

//   MPOStorage stor;
//   address public storageAddress;

//   constructor(address _storageAddress) public {
//     stor = MPOStorage(_storageAddress);
//   }

//   function setParams(address[] _responders, address _client, uint256 _threshold) public {
//     require(_threshold>0 && _threshold <= _responders.length);    
//     stor.setThreshold(_threshold);
//     stor.setResponders(_responders);
//     stor.setClient(_client);
//   }

//   function receive(uint256 id, string userQuery, bytes32 endpoint, bytes32[] endpointParams) external {

// //    Dispatch(msg.sender).respond1(id, "Hello World");

//     require(msg.sender==stor.getClient()&&
//             stor.getQueryStatus(id)==0);

//     stor.setQueryStatus(id,1);
//     // query each of the responders
//     for(uint i=0; i<stor.getNumResponders(); i++){      
//       OnChainProvider(stor.getResponderAddress(i)).receive(id, userQuery, endpoint, endpointParams);
//     }
//   }

//   function endpoint1(uint256 id, string userQuery, bytes32[] endpointParams) internal{
//     Dispatch(msg.sender).respond1(id, "Hello World");
//   }

//   function callback(uint256 queryId, string response) external {
//     require(stor.getAddressStatus(msg.sender) && 
//           !stor.onlyOneResponse(queryId, msg.sender)&&
//           stor.getQueryStatus(queryId) == 1);

//     stor.addResponse(queryId, response, msg.sender);
//     emit ReceivedResponse(queryId, msg.sender, response);
    
//     if(stor.getTally(queryId, response) >= stor.getThreshold()) {
//       stor.setQueryStatus(queryId, 2);
//       Client1(stor.getClient()).callback(queryId, response);
//     }
//   }
// }
