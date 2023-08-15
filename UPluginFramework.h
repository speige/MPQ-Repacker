//---------------------------------------------------------------------------
#pragma once
//---------------------------------------------------------------------------
#ifndef UPluginFrameworkH
#define UPluginFrameworkH
//---------------------------------------------------------------------------
#define DLLEXPORT extern "C" __declspec(dllexport) int __stdcall
//---------------------------------------------------------------------------
#include <System.hpp>
#include <Classes.hpp>
//---------------------------------------------------------------------------
// Definitions used in the plugin:
typedef int __stdcall (*OverrideFunc)(void);
struct TPluginInfo
{
	char* szName;
	char* szDescription;
	char* szAuthor;
    bool bHookFileFind;
	bool bHookFileUnpack;
	bool bHookFilePack;
};
struct TOverrideInfo
{
	DWORD Code;
	OverrideFunc Function;
	HINSTANCE hPlugin;
};
// Коды MPQ Repacker
#define CODE_FILE_SEARCH_START 0 // Start searching for files
#define CODE_FILE_SEARCH_END 1 // End of file search
#define CODE_FILES_UNPACKED 2 // Files are unpacked to a temporary folder
#define CODE_FILES_PACKED 3 // Files packed into MPQ archive
// -----------------
#define OVERRIDE_SEARCH 0 // Search plugin files
#define OVERRIDE_UNPACK 1 // Unpack the map with the plugin
#define OVERRIDE_PACK 2 // Pack map with plugin
// -----------------
// Definitions used only in the program:
enum TPFCondition {pfcFileFindHooked, pfcFileUnpackHooked, pfcFilePackHooked}; // Plugin Framework Condition
struct TPlugin
{
	UnicodeString Path;
	TPluginInfo Info;
	bool Enabled;
	HINSTANCE hPlugin;
};
struct TOverride
{
	bool Enabled;
	int PluginIndex;
	OverrideFunc Function;
};
struct TMPQRepackerOverrides
{
	TOverride Search;
	TOverride Unpack;
	TOverride Pack;
};
class TPluginFramework : public TObject
{
	protected:
		void __fastcall FindPlugins();
		TPlugin* PluginsList;
		unsigned int PluginsCount;
		UnicodeString Dir;
		TPluginInfo RequestPlgInfo(UnicodeString Path);
		void UnregisterOverridesByIndex(const int Index);
	public:
		TMPQRepackerOverrides Overrides;
		__fastcall TPluginFramework(const UnicodeString DirWithPlugins);
		__fastcall ~TPluginFramework();
		void __fastcall GetPluginList(TStrings* S);
		int IndexByName(const UnicodeString Name); // On error, returns -1
		int IndexByHInstance(HINSTANCE hPlg); // On error, returns -1
		void __fastcall UnloadPlugin(const int Index);
		void __fastcall LoadPlugin(const int Index);
		TPluginInfo GetPluginInfo(const int Index);
		int __fastcall SendCode(const int Index, const int Code); // Returns the response of the plugin
		void SendCodeToAll(const int Code, const TPFCondition IfFlag);
		int CallSettings(const unsigned Index, bool Execute = true); // If Execute == false, then only get the address and return FALSE if there is no nas function. triplets
};
//---------------------------------------------------------------------------
extern TPluginFramework* PluginManager; // Global Plugin Manager
//---------------------------------------------------------------------------
#endif
