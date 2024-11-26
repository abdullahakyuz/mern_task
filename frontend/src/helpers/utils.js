export const addLocal = (key,value) => {
    localStorage.setItem(key, JSON.stringify(value))
}