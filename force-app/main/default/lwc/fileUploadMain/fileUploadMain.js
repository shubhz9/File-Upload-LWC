import { LightningElement, api } from 'lwc';
import fetchFiles from '@salesforce/apex/FileUploadUtility.fetchFiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FileUploadMain extends LightningElement {
    @api recordId;
    fileData;
    fileList;
    columns = [
        { label: 'Title', fieldName: 'Name' },
        { label: 'Link', fieldName: 'DistributionPublicUrl', type: 'url', typeAttributes: { label: { fieldName: 'DistributionPublicUrl' }, target: '_blank' } }
    ];

    get acceptedFormats(){
        return ['.png', '.jpg','jpeg'];
    }

    handleUploadFinished(event){
        const files = event.detail.files[0];
        console.log('@@-- ' + files);
        this.connectedCallback();
        // var reader = new FileReader();

        // reader.onload = () => {
        //     var base64 = reader.result.split(',')[1];
        //     this.fileData = {
        //         'fileName' : files.Name,
        //         'base64' : base64,
        //         'recordId' : this.recordId
        //     }

        //     console.log('@@-- ' + this.fileData);
        // }

        // reader.readAsText(files);
        // const {fileName, base64, recordId} = this.fileData;

        // const successMessage = 'File Uploaded Successfully';
        // const errorMessage = 'Something went wrong';
        // uploadFile({base64, fileName, recordId}).then(result => {
        //     const toastEvent = new ShowToastEvent({
        //         successMessage, 
        //         variant:"success"
        //     });
        //     this.dispatchEvent(toastEvent);
        //     this.fileData = null;
        // })
    //     .catch(error => {
    //         const toastEvent = new ShowToastEvent({
    //             errorMessage, 
    //             variant:"error"
    //         });
    //         this.dispatchEvent(toastEvent);
    //         this.fileData = null;
    //         console.log('@@-- error'  + error);
    //     });
    }

    connectedCallback(){
        fetchFiles({recordId : this.recordId})
        .then(result => {
            this.fileList = result;
        })
        .catch(error => {
            const toastEvent = new ShowToastEvent({
                error, 
                variant:"error"
            });
            this.dispatchEvent(toastEvent);
            this.fileData = null;
            console.log('@@-- error'  + error);
        })
    }

}