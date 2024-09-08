export const objectMap = (obj: any, fn: (v: any, k: any, i: any) => any) =>
    Object.fromEntries(
        Object.entries(obj).map(
            ([k, v], i) => [k, fn(v, k, i)]
        )
    )

export function groupBy<T>(collection: T[], key: keyof T) {
    const groupedResult = collection.reduce((previous, current) => {

        if (!previous[current[key]]) {
            previous[current[key]] = [] as T[];
        }

        previous[current[key]].push(current);
        return previous;
    }, {} as any); // tried to figure this out, help!!!!!
    return groupedResult
}