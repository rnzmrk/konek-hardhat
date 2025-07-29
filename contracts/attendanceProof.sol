// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AttendanceProof
 * @dev A contract to manage event attendance and check-ins.
 */
contract AttendanceProof {
    address public organizer;
    uint public eventCount = 0;

    /**
     * @dev Event struct to store event details.
     * @param name Name of the event.
     * @param startTime Start time of the event.
     * @param endTime End time of the event.
     * @param attendees Mapping of addresses to attendance status.
     * @param exists Boolean to check if the event exists.
     */
    struct Event {
        string name;
        uint startTime;
        uint endTime;
        mapping(address => bool) attendees;
        bool exists;
    }

    mapping(uint => Event) public events;

    event EventCreated(uint eventId, string name, uint startTime, uint endTime);
    event CheckedIn(uint eventId, address attendee);
    event EventCancelled(uint eventId);
    event OrganizerUpdated(address newOrganizer);

    modifier onlyOrganizer() {
        require(msg.sender == organizer, "AttendanceProof: Not authorized");
        _;
    }

    constructor() {
        organizer = msg.sender;
    }

    /**
     * @dev Creates a new event.
     * @param name Name of the event.
     * @param startTime Start time of the event.
     * @param endTime End time of the event.
     */
    function createEvent(string memory name, uint startTime, uint endTime) external onlyOrganizer {
        require(startTime < endTime, "AttendanceProof: Invalid time range");

        Event storage newEvent = events[eventCount];
        newEvent.name = name;
        newEvent.startTime = startTime;
        newEvent.endTime = endTime;
        newEvent.exists = true;

        emit EventCreated(eventCount, name, startTime, endTime);
        eventCount++;
    }

    /**
     * @dev Allows an attendee to check in to an event.
     * @param eventId ID of the event to check in to.
     */
    function checkIn(uint eventId) external {
        Event storage e = events[eventId];
        require(e.exists, "AttendanceProof: Event does not exist");
        require(block.timestamp >= e.startTime && block.timestamp <= e.endTime, "AttendanceProof: Not in check-in window");
        require(!e.attendees[msg.sender], "AttendanceProof: Already checked in");

        e.attendees[msg.sender] = true;
        emit CheckedIn(eventId, msg.sender);
    }

    /**
     * @dev Checks if an attendee is attending an event.
     * @param eventId ID of the event.
     * @param attendee Address of the attendee.
     * @return bool True if the attendee is attending the event, false otherwise.
     */
    function isAttending(uint eventId, address attendee) external view returns (bool) {
        return events[eventId].attendees[attendee];
    }

    /**
     * @dev Cancels an event.
     * @param eventId ID of the event to cancel.
     */
    function cancelEvent(uint eventId) external onlyOrganizer {
        Event storage e = events[eventId];
        require(e.exists, "AttendanceProof: Event does not exist");

        e.exists = false;
        emit EventCancelled(eventId);
    }

    /**
     * @dev Updates the organizer of the contract.
     * @param newOrganizer Address of the new organizer.
     */
    function updateOrganizer(address newOrganizer) external onlyOrganizer {
        require(newOrganizer != address(0), "AttendanceProof: Invalid address");

        organizer = newOrganizer;
        emit OrganizerUpdated(newOrganizer);
    }

    /**
     * @dev Gets the details of an event.
     * @param eventId ID of the event.
     * @return name Name of the event.
     * @return startTime Start time of the event.
     * @return endTime End time of the event.
     * @return exists Boolean indicating if the event exists.
     */
    function getEventDetails(uint eventId) external view returns (string memory name, uint startTime, uint endTime, bool exists) {
        Event storage e = events[eventId];
        return (e.name, e.startTime, e.endTime, e.exists);
    }
}
