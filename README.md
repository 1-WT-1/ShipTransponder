# Ship Transponder

Adds the ship's variant name or model to the OMS target list.

## Configuration

-   **Display Preference**:
    -   Sets whether to show the `Name` or `Model` first. The mod automatically falls back to the other option if the preferred one is not available.
    -   **Default**: `Name`
-   **Show Non-Hailable**:
    -   If enabled, the mod will attempt to display names for non-hailable targets, such as derelicts.
    -   **Default**: `Disabled`
-   **Show Untranslated Keys**:
    -   When enabled, displays the raw translation key (e.g., `SHIP_INTERNAL_NAME`) instead of 'UNKNOWN' if translation is not found.
    -   **Default**: `Disabled`
-   <details>
    <summary><b>[SPOILER]</b></summary>
    
    -   **Dynamic Hybrid Naming**:
        -   If enabled, the Hybrid ship's identity will change frequently. By default, it is fixed for each encounter.
        -   **Default**: `Disabled`
    </details>

> [!WARNING]
> Requires HevLib to function
> https://github.com/rwqfsfasxc100/HevLib/releases
