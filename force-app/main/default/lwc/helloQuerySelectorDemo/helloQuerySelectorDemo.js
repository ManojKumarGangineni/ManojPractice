import { LightningElement } from 'lwc';

export default class HelloQuerySelectorDemo extends LightningElement {

    fetchElements(){
      
        this.template.querySelector('h1')
        // this.template.querySelectorAll('div')
       console.log(fetchelement.innerText)
    }

}