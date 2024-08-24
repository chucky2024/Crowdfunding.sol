// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    // Define a structure for a campaign
    struct Campaign {
        string title;
        string description;
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

    // Mapping from campaign ID to Campaign
    mapping(uint => Campaign) public campaigns;
    // Counter for campaign IDs
    uint public campaignCount;

    // Event emitted when a new campaign is created
    event CampaignCreated(uint campaignId, string title, address benefactor, uint goal, uint deadline);
    // Event emitted when a donation is made
    event DonationReceived(uint campaignId, address donor, uint amount);
    // Event emitted when a campaign ends
    event CampaignEnded(uint campaignId, uint amountRaised, address benefactor);

    // Function to create a new campaign
    function createCampaign(string memory _title, string memory _description, address payable _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal must be greater than 0");
        require(_duration > 0, "Duration must be greater than 0");

        campaignCount++;
        uint deadline = block.timestamp + _duration;

        campaigns[campaignCount] = Campaign({
            title: _title,
            description: _description,
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(campaignCount, _title, _benefactor, _goal, deadline);
    }

    // Function to donate to a campaign
    function donate(uint _campaignId) public payable {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(!campaign.ended, "Campaign has already ended");
        require(msg.value > 0, "Donation must be greater than 0");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // Function to end a campaign and transfer funds to the benefactor
    function endCampaign(uint _campaignId) public {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet");
        require(!campaign.ended, "Campaign has already ended");
        require(msg.sender == campaign.benefactor, "Only the benefactor can end the campaign");

        campaign.ended = true;

        // Transfer the funds to the benefactor
        campaign.benefactor.transfer(campaign.amountRaised);

        emit CampaignEnded(_campaignId, campaign.amountRaised, campaign.benefactor);
    }
}