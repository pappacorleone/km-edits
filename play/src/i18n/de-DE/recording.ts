import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Aktualisieren",
    title: "Ihre Aufnahmeliste",
    noRecordings: "Keine Aufnahmen gefunden",
    errorFetchingRecordings: "Fehler beim Abrufen der Aufnahmen",
    expireIn: "Läuft ab in {days} Tag{days}",
    download: "Herunterladen",
    close: "Schließen",
    ok: "Ok",
    recordingList: "Aufnahmen",
    contextMenu: {
        openInNewTab: "In neuem Tab öffnen",
        delete: "Löschen",
    },
    notification: {
        deleteNotification: "Aufnahme erfolgreich gelöscht",
        deleteFailedNotification: "Löschen der Aufnahme fehlgeschlagen",
        recordingStarted: "{name} hat eine Aufnahme gestartet.",
        downloadFailedNotification: "Herunterladen der Aufnahme fehlgeschlagen",
    },
    actionbar: {
        title: {
            start: "Aufnahme starten",
            stop: "Aufnahme beenden",
            inpProgress: "Eine Aufnahme läuft",
        },
        desc: {
            needLogin: "Sie müssen angemeldet sein, um aufzunehmen.",
            needPremium: "Sie müssen Premium sein, um aufzunehmen.",
            advert: "Alle Teilnehmer werden benachrichtigt, dass Sie eine Aufnahme starten.",
            yourRecordInProgress: "Aufnahme läuft, klicken Sie, um sie zu beenden.",
            inProgress: "Eine Aufnahme läuft",
            notEnabled: "Aufnahmen sind für diese Welt deaktiviert.",
        },
    },
};

export default recording;
