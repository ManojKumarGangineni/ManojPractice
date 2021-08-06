<aura:application extends="force:slds">
    
    <aura:attribute name="openRegistrationForm" type="Boolean" default = "false"/>
    <aura:attribute name="ButtonLabel" type ="string" default = "Open registration form" />
    <lightning:button label= "{!v.ButtonLabel}" onclick= "{!c.openCloseRegistratinoForm}" />
    
    <aura:if isTrue = "{!v.openRegistrationForm}" >
    <c:RegistrationForm />
        </aura:if>
</aura:application>