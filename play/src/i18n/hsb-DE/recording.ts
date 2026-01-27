import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Aktualizować",
    title: "Waša lisćina nagraćow",
    noRecordings: "Žane nagraća namakane",
    errorFetchingRecordings: "Zmylk je nastał při wotwołowanju nagraćow",
    expireIn: "Spadnje za {days} dźeń{days}",
    download: "Sćahnyć",
    close: "Začinić",
    ok: "W porjadku",
    recordingList: "Nagraća",
    contextMenu: {
        openInNewTab: "W nowym rajtarku wočinić",
        delete: "Zhašeć",
    },
    notification: {
        deleteNotification: "Nagraće wuspěšnje zhašene",
        deleteFailedNotification: "Zhašowanje nagraća je so njeradźiło",
        recordingStarted: "{name} je nagraće započał.",
        downloadFailedNotification: "Sćehnjenje nagraća je so njeradźiło",
    },
    actionbar: {
        title: {
            start: "Nagraće započeć",
            stop: "Nagraće zastajić",
            inpProgress: "Nagraće běži",
        },
        desc: {
            needLogin: "Dyrbiće přizjewjeny być, zo by nagrał.",
            needPremium: "Dyrbiće premium być, zo by nagrał.",
            advert: "Wšitcy wobdźělnicy dostanu powěsć, zo nagraće započinjeće.",
            yourRecordInProgress: "Nagraće běži, klikńće, zo by je zastajił.",
            inProgress: "Nagraće běži",
            notEnabled: "Nagraća su za tutón swět znjemóžnjene.",
        },
    },
};

export default recording;
