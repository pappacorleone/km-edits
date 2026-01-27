import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "تحديث",
    title: "قائمة التسجيلات الخاصة بك",
    noRecordings: "لم يتم العثور على تسجيلات",
    errorFetchingRecordings: "حدث خطأ أثناء جلب التسجيلات",
    expireIn: "ينتهي خلال {days} يوم{days}",
    download: "تحميل",
    close: "إغلاق",
    ok: "موافق",
    recordingList: "التسجيلات",
    contextMenu: {
        openInNewTab: "فتح في علامة تبويب جديدة",
        delete: "حذف",
    },
    notification: {
        deleteNotification: "تم حذف التسجيل بنجاح",
        deleteFailedNotification: "فشل حذف التسجيل",
        recordingStarted: "{name} بدأ تسجيلاً.",
        downloadFailedNotification: "فشل تحميل التسجيل",
    },
    actionbar: {
        title: {
            start: "بدء التسجيل",
            stop: "إيقاف التسجيل",
            inpProgress: "تسجيل قيد التنفيذ",
        },
        desc: {
            needLogin: "تحتاج إلى تسجيل الدخول للتسجيل.",
            needPremium: "تحتاج إلى اشتراك مميز للتسجيل.",
            advert: "سيتم إشعار جميع المشاركين بأنك تبدأ تسجيلاً.",
            yourRecordInProgress: "التسجيل قيد التنفيذ، انقر لإيقافه.",
            inProgress: "تسجيل قيد التنفيذ",
            notEnabled: "التسجيلات معطلة لهذا العالم.",
        },
    },
};

export default recording;
