import { LightningElement } from 'lwc';

export default class HelloConditionalRendering extends LightningElement {
    isvisible = false;
    ischecked = false;

    handleClick(){
        this.isvisible = true;
    }
    checkBoxHandler(){
        this.ischecked = true;

        
    }
}