<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Expired_Status</fullName>
        <field>Referral_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Expired Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Save_Assignment_Date</fullName>
        <field>Assignment_Date__c</field>
        <formula>Today()</formula>
        <name>Save Assignment Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Save_Converted_Date</fullName>
        <field>Converted_Date__c</field>
        <formula>Today()</formula>
        <name>Save Converted Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assignment Date Catch</fullName>
        <actions>
            <name>Save_Assignment_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(TEXT(Referral_Status__c) == &apos;Assigned&apos;,ISCHANGED(Referral_Status__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Converted Date Catch</fullName>
        <actions>
            <name>Save_Converted_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(TEXT(Referral_Status__c) == &apos;Converted&apos;,ISCHANGED(Referral_Status__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Referral Expiration</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Trade_Ally_Referral__c.Referral_Status__c</field>
            <operation>equals</operation>
            <value>Assigned</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Expired_Status</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
