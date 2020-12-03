/** @noSelfInFile */

declare namespace os {
    /** @tupleReturn */
    function pullEvent(targetEvent?: string): [string, ...any];
}