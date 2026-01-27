import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "Aktualizěrowaś",
    title: "Waša lisćina nagraśow",
    noRecordings: "Žedne nagraśa namakane",
    errorFetchingRecordings: "Zmólka jo nastała pśi wótwołowanju nagraśow",
    expireIn: "Spadnjo za {days} źeń{days}",
    download: "Ześěgnuś",
    close: "Zacyniś",
    ok: "W pórěźe",
    recordingList: "Nagraśa",
    contextMenu: {
        openInNewTab: "W nowem rejtariku wócyniś",
        delete: "Lašowaś",
    },
    notification: {
        deleteNotification: "Nagraśe wuspěšnje wulašowane",
        deleteFailedNotification: "Lašowanje nagraśa jo se njeraźiło",
        recordingStarted: "{name} jo nagraśe zachopił.",
        downloadFailedNotification: "Ześěgnjenje nagraśa jo se njeraźiło",
    },
    actionbar: {
        title: {
            start: "Nagraśe zachopiś",
            stop: "Nagraśe zastajiś",
            inpProgress: "Nagraśe běžy",
        },
        desc: {
            needLogin: "Musyśo pśizjawjony byś, aby nagrał.",
            needPremium: "Musyśo premium byś, aby nagrał.",
            advert: "Wšykne wobźělniki dostanu powěźeńku, až nagraśe zachopijośo.",
            yourRecordInProgress: "Nagraśe běžy, klikniśo, aby jo zastajił.",
            inProgress: "Nagraśe běžy",
            notEnabled: "Nagraśa su za toś ten swět znjemóžnjone.",
        },
    },
};

export default recording;
