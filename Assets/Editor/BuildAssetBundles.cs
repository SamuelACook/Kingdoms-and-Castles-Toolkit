using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;
using System.IO;

public class BuildAssetBundles : MonoBehaviour {

    [MenuItem("Mods & DLC/Build Hat Mod Asset Bundle")]
    static void BuildMapABs()
    {
        // Create the array of bundle build details.
        AssetBundleBuild[] buildMap = new AssetBundleBuild[1];
        
        string[] hats = new string[16];
        hats[0] =  "Assets/DeveloperMods/Hats/BrownHat.prefab";
        hats[1] =  "Assets/DeveloperMods/Hats/BrownNewsboyHat.prefab";
        hats[2] =  "Assets/DeveloperMods/Hats/FarmerGreenHat.prefab";
        hats[3] =  "Assets/DeveloperMods/Hats/FarmerPlainHat.prefab";
        hats[4] =  "Assets/DeveloperMods/Hats/GrayNewsboyHat.prefab";
        hats[5] =  "Assets/DeveloperMods/Hats/PurpleLadyHat.prefab";
        hats[6] =  "Assets/DeveloperMods/Hats/TopHat.prefab";
        hats[7] =  "Assets/DeveloperMods/Hats/WhitePinkLadyHat.prefab";
                        
        hats[8] =  "Assets/DeveloperMods/Hats/HatBlack.material";
        hats[9] =  "Assets/DeveloperMods/Hats/HatBrown.material";
        hats[10] = "Assets/DeveloperMods/Hats/HatGray.material";
        hats[11] = "Assets/DeveloperMods/Hats/HatGreen.material";
        hats[12] = "Assets/DeveloperMods/Hats/HatPink.material";
        hats[13] = "Assets/DeveloperMods/Hats/HatPurple.material";
        hats[14] = "Assets/DeveloperMods/Hats/HatStraw.material";
        hats[15] = "Assets/DeveloperMods/Hats/HatWhite.material";

        buildMap[0].assetNames = hats;

        buildMap[0].assetBundleName = "hats_windows32";
        BuildPipeline.BuildAssetBundles("Assets/Hats", buildMap, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows);

        buildMap[0].assetBundleName = "hats_windows64";
        BuildPipeline.BuildAssetBundles("Assets/Hats", buildMap, BuildAssetBundleOptions.None, BuildTarget.StandaloneWindows64);
        
        buildMap[0].assetBundleName = "hats_osx";
        BuildPipeline.BuildAssetBundles("Assets/Hats", buildMap, BuildAssetBundleOptions.None, BuildTarget.StandaloneOSX);
        
        buildMap[0].assetBundleName = "hats_linux";
        BuildPipeline.BuildAssetBundles("Assets/Hats", buildMap, BuildAssetBundleOptions.None, BuildTarget.StandaloneLinux64);
    }

    [MenuItem("Mods & DLC/Build Decorations")]
    static public void BuildDecorationsDLC()
    {
        // Create the array of bundle build details.
        AssetBundleBuild[] buildMap = new AssetBundleBuild[1];
        
        List<string> assets = new List<string>();

        string dlcPath = Path.Combine(Application.dataPath, "../builds/decorations");
        if (!Directory.Exists(dlcPath))
        {
            Directory.CreateDirectory(dlcPath);
        }

        var files = Directory.GetFiles(dlcPath);
        foreach (var item in files)
        {
            File.Delete(item);
        }

        var guids = AssetDatabase.FindAssets("*", new string[] { "Assets/DecorationDLC" });
        foreach (var guid in guids)
        {
            assets.Add(AssetDatabase.GUIDToAssetPath(guid));
        }

        buildMap[0].assetNames = assets.ToArray();

        buildMap[0].assetBundleName = "decorations_win32";
        BuildPipeline.BuildAssetBundles("builds/decorations", buildMap, BuildAssetBundleOptions.StrictMode, BuildTarget.StandaloneWindows);

        buildMap[0].assetBundleName = "decorations_win64";
        BuildPipeline.BuildAssetBundles("builds/decorations", buildMap, BuildAssetBundleOptions.StrictMode, BuildTarget.StandaloneWindows64);

        buildMap[0].assetBundleName = "decorations_osx";
        BuildPipeline.BuildAssetBundles("builds/decorations", buildMap, BuildAssetBundleOptions.StrictMode, BuildTarget.StandaloneOSX);

        buildMap[0].assetBundleName = "decorations_linux";
        BuildPipeline.BuildAssetBundles("builds/decorations", buildMap, BuildAssetBundleOptions.StrictMode, BuildTarget.StandaloneLinux64);
    }
}