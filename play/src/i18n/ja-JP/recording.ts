import type { DeepPartial } from "../DeepPartial";
import type { Translation } from "../i18n-types";

const recording: DeepPartial<Translation["recording"]> = {
    refresh: "更新",
    title: "録画リスト",
    noRecordings: "録画が見つかりません",
    errorFetchingRecordings: "録画の取得中にエラーが発生しました",
    expireIn: "{days}日{days}で期限切れ",
    download: "ダウンロード",
    close: "閉じる",
    ok: "OK",
    recordingList: "録画",
    contextMenu: {
        openInNewTab: "新しいタブで開く",
        delete: "削除",
    },
    notification: {
        deleteNotification: "録画が正常に削除されました",
        deleteFailedNotification: "録画の削除に失敗しました",
        recordingStarted: "{name}が録画を開始しました。",
        downloadFailedNotification: "録画のダウンロードに失敗しました",
    },
    actionbar: {
        title: {
            start: "録画を開始",
            stop: "録画を停止",
            inpProgress: "録画が進行中です",
        },
        desc: {
            needLogin: "録画するにはログインが必要です。",
            needPremium: "録画するにはプレミアムが必要です。",
            advert: "すべての参加者に、録画を開始することを通知します。",
            yourRecordInProgress: "録画が進行中です。クリックして停止します。",
            inProgress: "録画が進行中です",
            notEnabled: "このワールドでは録画が無効になっています。",
        },
    },
};

export default recording;
