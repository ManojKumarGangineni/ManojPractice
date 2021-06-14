import { LightningElement } from 'lwc';

export default class TestDataTableViewOrHide extends LightningElement {
    isFamilyAvailable = false;
   
   familyList = [
       {
           Id : 1,
           name : 'Manoj',
       },
       {
        Id : 2,
        name : 'Divya',
    },
    {
        Id : 3,
        name : 'Devansh',
    },
    {
        Id : 4,
        name : 'Usha',
    },
    {
        Id : 5,
        name : 'Subrmanayam',
    }
   ]

   handleClick(){
       console.log(this.isFamilyAvailable);
    this.isFamilyAvailable = true;
    console.log(this.isFamilyAvailable);
   }

}