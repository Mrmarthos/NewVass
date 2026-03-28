import { LightningElement, api, track } from 'lwc';
import processCSV from '@salesforce/apex/CSVProcessor.processCSV';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateProjectLines from '@salesforce/apex/CSVProcessor.updateProjectLines';

const VISIBLE_COLUMNS = [
    { fieldName: 'OPPCODE', label: 'Offer Code' },
    { fieldName: 'DESC_BUSINESSUNIT', label: 'Business Unit' },
    { fieldName: 'DESC_SERVICELINE', label: 'Service Line' },
    { fieldName: 'DESC_PRACTISE', label: 'Practice' },
    { fieldName: 'DESC_ROL', label: 'Role' },
    { fieldName: 'STARTDATE', label: 'Start Date'},
    { fieldName: 'ENDDATE', label: 'End Date'}
];
export default class FileUploadEconomic extends LightningElement {
    @api recordId;
    @track groupedData = [];
    @track showModal = false;
        @track showSpinner = false;
    @track csvWarning = '';
    @track hideContinueButton = false;
    @track rawCsvContent = '';
    columns = VISIBLE_COLUMNS;
    rawCsvRows = []; // <-- Aquí guardamos las filas originales del CSV

    get acceptedFormats() {
        return ['.csv'];
    }

    handleUploadFinished(event) {
         this.showSpinner = true;
        const uploadedFile = event.detail.files[0];
        const documentId = uploadedFile.documentId;

        processCSV({ documentId: documentId, opportunityId: this.recordId })
            .then(result => {
                // Guarda las filas originales del CSV para usarlas en "Continue"
                this.rawCsvRows = result.rows;
                this.rawCsvContent = result.csvContent;

                    // Map rows and group as before...
                    const rows = result.rows.map((row, idx) => {
                let filtered = { id: idx + '' };
                VISIBLE_COLUMNS.forEach(col => {
                filtered[col.fieldName] = row[col.fieldName] || '';
                });
                return filtered;
                });

                const groupsMap = new Map();
                rows.forEach(row => {
                    const key = row.DESC_BUSINESSUNIT + '___' + row.DESC_SERVICELINE;
                    if (!groupsMap.has(key)) {
                        groupsMap.set(key, {
                            groupName: row.DESC_BUSINESSUNIT + ' - ' + row.DESC_SERVICELINE,
                            rows: []
                        });
                    }
                    groupsMap.get(key).rows.push(row);
                });

                this.groupedData = Array.from(groupsMap.values());
                this.csvWarning = result.warningMessage;
                this.hideContinueButton = !!result.warningMessage;
                this.showSpinner = false;
                this.showModal = true;
            })
            .catch(error => {
                console.error('Error in processCSV:', JSON.stringify(error));
                this.showErrorToast(error);
                this.showSpinner = false;
            });
    }

    handleCancel() {
        this.showModal = false;
    }

    handleContinue() {
        console.log('csvContent a enviar:', this.rawCsvContent?.substring(0, 20) + '...');
        
        updateProjectLines({
            opportunityId: this.recordId,
            csvRows: this.rawCsvRows,
            csvContent: this.rawCsvContent
        })
        .then(() => {
            this.showModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Project lines updated successfully.',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
            console.error('Error in updateProjectLines:', JSON.stringify(error));
            this.showErrorToast(error);
        });
    }

showErrorToast(error) {
    let errorMessage = 'Error desconocido';
    
    // Debuggear estructura completa del error
    console.log('Error completo:', JSON.stringify(error, null, 2));
    
    if (error?.body?.message) {
        errorMessage = error.body.message;
    } 
    else if (error?.message) {
        errorMessage = error.message;
    }
    else if (error?.body?.exceptionType === 'System.AuraHandledException') {
        errorMessage = error.body.exceptionMessage;
    }

    // Forzar muestra del mensaje completo en consola
    console.error('Mensaje de error procesado:', errorMessage);
    
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: errorMessage,
            variant: 'error',
            mode: 'sticky'
        })
    );
}



}