using UnityEditor;

namespace Firebase.Editor
{
    /// <summary>
    /// Enable/Disable <b>Firebase</b> automatic <see cref="GenerateXmlFromGoogleServicesJson"/> file parser, from
    /// a Unity Editor menu. This flag is saved in <see cref="EditorPrefs"/>
    /// </summary>
    /// <remarks>
    /// <b>PS:</b> If you're facing Unity Editor freezes after install Firebase Unity SDK, and you make sure that
    /// <i>google-services.xml</i> was already generated, you can try turn off this settings in order
    /// to improve Editor performance.
    /// </remarks>
    [InitializeOnLoad]
    public static class AutomaticCheckingSetting
    {
        private const string MENU_NAME = "Window/Firebase/Check Configuration Automatically";
        private const string PREFERENCES_KEY = "firebase-check-config-automatically";

        public static bool IsEnabled
        {
            // Return true if the pref is not set
            get => EditorPrefs.GetBool(PREFERENCES_KEY, true);
            // Saving editor state
            set => EditorPrefs.SetBool(PREFERENCES_KEY, value);
        }
        
        // Called on load thanks to the InitializeOnLoad attribute
        static AutomaticCheckingSetting() {

            // Delaying until first editor tick so that the menu
            // will be populated before setting check state, and
            // re-apply correct action
            
            // Set checkmark on menu item
            EditorApplication.delayCall += () => Menu.SetChecked(MENU_NAME, IsEnabled);
        }
        
        [MenuItem(MENU_NAME)]
        private static void ToggleSetting()
        {
            IsEnabled = !IsEnabled;
            Menu.SetChecked(MENU_NAME, IsEnabled);
        }
    }
}
