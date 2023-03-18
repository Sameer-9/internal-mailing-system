import { writable } from "svelte/store";

export const inboxConversations = writable([
    {
        id: crypto.randomUUID(),
        sender: 'Test Sender',
        message: "cbvwoiviwovwviwoivii weovwovwiov wviwivowiov",
        date: 'Mar 26',
        isRead: false,
        isStarred: false,
        isChecked: false
    },
    {
        id: crypto.randomUUID(),
        sender: 'Test Sender wv vwvwivowv',
        subject: "loremwwwpvwpbvpwevpev v wpvhwp ehvpwhevphwepvh wev",
        message: "cbvwoiviwovwviwoivii weovwovwiov wviwivowiov",
        date: 'Mar 26',
        isRead: false,
        isStarred: false,
        isChecked: false
    },
    {
        id: crypto.randomUUID(),
        sender: 'Test Sender vwvwvl',
        subject: "loremwwwpvwpbvpwevpev v wpvhwp ehvpwhevphwepvh wev",
        message: "cbvwoiviwovwviwoivii weovwovwiov wviwivowiov",
        date: 'Mar 26',
        isRead: true,
        isStarred: false,
        isChecked: false
    },
 ]);

/**
 * @param {any} conversationObject
 */
export function updateInboxConversation(conversationObject) {

    inboxConversations.update(state => {
        return state.map(obj => {
            if(conversationObject?.id == obj?.id) {
                obj = conversationObject;
            } 
            return obj;
        })
    })
}

export function SelectAllConversation(isChecked = false) {
    inboxConversations.update(state => {
        return state.map(obj => {
              obj.isChecked = isChecked;
            return obj;
        })
    })
}