import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Aggiorna",
    title: "La tua lista di registrazioni",
    noRecordings: "Nessuna registrazione trovata",
    errorFetchingRecordings: "Si è verificato un errore durante il recupero delle registrazioni",
    expireIn: "Scade tra {days} giorno{days}",
    download: "Scarica",
    close: "Chiudi",
    ok: "Ok",
    recordingList: "Registrazioni",
    contextMenu: {
        openInNewTab: "Apri in una nuova scheda",
        delete: "Elimina",
    },
    notification: {
        deleteNotification: "Registrazione eliminata con successo",
        deleteFailedNotification: "Errore nell'eliminazione della registrazione",
        recordingStarted: "{name} ha avviato una registrazione.",
        downloadFailedNotification: "Errore nel download della registrazione",
    },
    actionbar: {
        title: {
            start: "Avvia registrazione",
            stop: "Interrompi registrazione",
            inpProgress: "Una registrazione è in corso",
        },
        desc: {
            needLogin: "Devi essere connesso per registrare.",
            needPremium: "Devi essere premium per registrare.",
            advert: "Tutti i partecipanti saranno notificati che stai avviando una registrazione.",
            yourRecordInProgress: "Registrazione in corso, clicca per interromperla.",
            inProgress: "Una registrazione è in corso",
            notEnabled: "Le registrazioni sono disabilitate per questo mondo.",
        },
    },
};

export default recording;
