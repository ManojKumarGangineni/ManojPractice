import { LightningElement,track } from 'lwc';

export default class HelloWorld extends LightningElement {
Name = 'Manoj'
ParentName = 'Gangineni'
var1 = 10;
var2 = 20 ;

@track ManojObjVal = {city:'Bangalore',pincode:560033}
@track familyNameArray = ['Gangineni', 'Divya','Devansh','Manoj']


    getUpdateValue(event){
        console.log('event.target.valueforst' + event.target.value);
    this.ParentName = event.target.value;
}
 getCityValue(event){
    console.log('event.target.value' + event.target.value);
   this.ManojObjVal.city = event.target.value;
    th//is.familyListArray[0] = event.target.value;
 }

 get familyList(){
     console.log(this.familyNameArray);
     return this.familyNameArray[0].toUpperCase();
 }
 get calculateNumber(){
     return this.var1* this.var2;
 }

} 
