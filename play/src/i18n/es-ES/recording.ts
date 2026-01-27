import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Actualizar",
    title: "Tu lista de grabaciones",
    noRecordings: "No se encontraron grabaciones",
    errorFetchingRecordings: "Ocurrió un error al recuperar las grabaciones",
    expireIn: "Caduca en {days} día{days}",
    download: "Descargar",
    close: "Cerrar",
    ok: "De acuerdo",
    recordingList: "Grabaciones",
    contextMenu: {
        openInNewTab: "Abrir en una nueva pestaña",
        delete: "Eliminar",
    },
    notification: {
        deleteNotification: "Grabación eliminada correctamente",
        deleteFailedNotification: "Error al eliminar la grabación",
        recordingStarted: "{name} ha comenzado una grabación.",
        downloadFailedNotification: "Error al descargar la grabación",
    },
    actionbar: {
        title: {
            start: "Iniciar grabación",
            stop: "Detener grabación",
            inpProgress: "Una grabación está en curso",
        },
        desc: {
            needLogin: "Necesitas iniciar sesión para grabar.",
            needPremium: "Necesitas ser premium para grabar.",
            advert: "Todos los participantes serán notificados de que estás iniciando una grabación.",
            yourRecordInProgress: "Grabación en curso, haz clic para detenerla.",
            inProgress: "Una grabación está en curso",
            notEnabled: "Las grabaciones están deshabilitadas para este mundo.",
        },
    },
};

export default recording;
