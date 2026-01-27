import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Actualitzar",
    title: "La vostra llista d'enregistraments",
    noRecordings: "No s'han trobat enregistraments",
    errorFetchingRecordings: "S'ha produït un error en recuperar els enregistraments",
    expireIn: "Caduca en {days} dia{days}",
    download: "Descarregar",
    close: "Tancar",
    ok: "D'acord",
    recordingList: "Enregistraments",
    contextMenu: {
        openInNewTab: "Obrir en una nova pestanya",
        delete: "Eliminar",
    },
    notification: {
        deleteNotification: "Enregistrament eliminat correctament",
        deleteFailedNotification: "Error en eliminar l'enregistrament",
        recordingStarted: "{name} ha començat un enregistrament.",
        downloadFailedNotification: "Error en descarregar l'enregistrament",
    },
    actionbar: {
        title: {
            start: "Començar enregistrament",
            stop: "Aturar enregistrament",
            inpProgress: "S'està realitzant un enregistrament",
        },
        desc: {
            needLogin: "Has d'iniciar sessió per enregistrar.",
            needPremium: "Necessites ser premium per enregistrar.",
            advert: "Tots els participants seran notificats que estàs començant un enregistrament.",
            yourRecordInProgress: "Enregistrament en curs, feu clic per aturar-lo.",
            inProgress: "S'està realitzant un enregistrament",
            notEnabled: "Els enregistraments estan desactivats per a aquest món.",
        },
    },
};

export default recording;
