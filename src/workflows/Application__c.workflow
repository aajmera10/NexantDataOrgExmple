<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Active_Status</fullName>
        <description>This action set &apos;Active&apos; value in App status field</description>
        <field>Application_Status__c</field>
        <literalValue>Active</literalValue>
        <name>Set Active Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Pending_Status</fullName>
        <description>This action set &apos;Pending&apos; value in App status field</description>
        <field>Application_Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Set Pending Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_status</fullName>
        <description>This action set &apos;In Review&apos; value in App status field</description>
        <field>Application_Status__c</field>
        <literalValue>In Review</literalValue>
        <name>Set In Review Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
