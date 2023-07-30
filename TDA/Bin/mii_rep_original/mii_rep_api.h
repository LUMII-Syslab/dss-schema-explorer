//---------------------------------------------------------------------------
#ifndef ect_data_apiH
#define ect_data_apiH

#ifdef __BUILDING_ECT_DATA_DLL
#define __EXPORT_TYPE __export
#define __EXPORT_TYPE1 extern "C" __declspec(dllexport)
#else
#define __EXPORT_TYPE __import
#define __EXPORT_TYPE1 extern "C" __declspec(dllimport)
#endif

#include <vcl.h>
//------------------------------------------------------------------------------
// TO BE DELETED
//------------------------------------------------------------------------------
__EXPORT_TYPE1 int __fastcall CheckPropertyValue(long PropertyTypeId, WideString Value);
__EXPORT_TYPE1 int ObjectIsValid(long ObjectId);
__EXPORT_TYPE1 int GetLinkTypeAttributes(long LinkTypeId,
                   long &SideObjTypeId2, char &Cardinality2,
                   long &InverseLinkTypeId, WideString &FieldName1, WideString &FieldName2); // 0 - error
//Old version - FieldName1, FieldNam2, TableName, IsDimensionLink are not used
__EXPORT_TYPE1 long CreateLinkType1(WideString Name, WideString Description, WideString InverseName,
                    long ObjectTypeId1, char Cardinality1, char Role1,
                    long ObjectTypeId2, char Cardinality2, char Role2,
                    WideString FieldName1, WideString FieldName2, WideString TableName,
                    char IsDimensionLink);  // 0 - error
__EXPORT_TYPE1 int GetObjectTypeAttributes(long ObjectTypeId, WideString &Name, WideString &Description,
                    WideString &TableName, long &ExtendsTypeId);  // 0 - error
__EXPORT_TYPE1 long CreateObjectType1(long ExtendsTypeId, WideString Name, WideString Description,
                    WideString TableName, WideString IconFileName, char IsDimensionObject,
                    WideString HelpFileName, long HelpContextId, char InstancesReadOnly); // returns id, or 0 - error
__EXPORT_TYPE1 int UpdateObjectType(long ExtendsTypeId, long ObjectTypeId, WideString Name, WideString Description,
                   WideString TableName, WideString IconFileName); // 0 - error
__EXPORT_TYPE1 int GetPropertyTypeAttributes(long PropertyTypeId, char &BaseType, char &Cardinality,
                    WideString &DefaultValue, WideString &FieldName); // 0 - error
__EXPORT_TYPE1 long CreatePropertyType(WideString Name, WideString Description, char BaseType,
                    char Cardinality, WideString DefaultValue, WideString FieldName); // returns id, or 0 - error
__EXPORT_TYPE1 int UpdatePropertyType(long PropertyTypeId, WideString Name, WideString Description, char BaseType,
                    char Cardinality, WideString DefaultValue, WideString FieldName); // 0 - error

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// NEWS
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

__EXPORT_TYPE1 int ImportDataFromXMLFileMOLA(TComponent* Owner); //02.10.2006 EC
__EXPORT_TYPE1 long ImportXMLMOLA(void* ParamBlock); //02.10.2006 EC


__EXPORT_TYPE1 int ExportScopeObjectsAsXMLFile(TComponent* Owner, long ObjectId);

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// MESSAGING
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

// Displays OK message box
__EXPORT_TYPE1 void MXXW(WideString pattern, WideString s1, WideString s2, WideString s3);
// Appends message to log file
__EXPORT_TYPE1 void PXXW(WideString pattern, WideString s1, WideString s2, WideString s3);
// Displays YESNO message box, returns 1 on YES, 0 - on NO
__EXPORT_TYPE1 int QXXW(WideString pattern, WideString s1, WideString s2, WideString s3);

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// TYPE MANAGEMENT
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

// Property type and link type cardinalities
#define Card_01 1
#define Card_0N 2
#define Card_1 3
#define Card_1N 4

// Property base types
#define BaseType_STRING 0
#define BaseType_INTEGER 1
#define BaseType_FLOAT 2
#define BaseType_BOOLEAN 3

// old version
#define BaseType_TEXT 4
// new version
#define BaseType_HYPER_TEXT 4

#define BaseType_DATE_TIME 5
#define BaseType_EXPRESSION 6
#define BaseType_ENUMERATION 7
#define BaseType_RESOURCE_REF 99

// Object type roles in link types
#define Role_Group 1
#define Role_Member 11
#define Role_Aggregate 2
#define Role_Part 12
#define Role_DependentPartner 3
#define Role_IndependentPartner 4


//------------------------------------------------------------------------------
// GENERAL
//------------------------------------------------------------------------------
__EXPORT_TYPE1 long GetEntityPackageId(long Identifier);

__EXPORT_TYPE1 WideString GetShortTypeName(long TypeId); // returns name without packages, empty string - error
__EXPORT_TYPE1 WideString GetTypeName(long TypeId);  // returns full name - with packages, empty string - error

// opens file dialog, produces 2 files: type_ids.h, type_ids.cpp
__EXPORT_TYPE1 void GenerateTypeIdFiles();
// opens file dialog, produces 1 file: *.sql
//__EXPORT_TYPE1 int GenerateDBInitScriptXXXX(); // returns 0 on error or cancel

__EXPORT_TYPE1 void ExportPackage(long PackageId);
__EXPORT_TYPE1 int ImportPackages(); // returns 0 on error

//------------------------------------------------------------------------------
// OBJECT TYPES
//------------------------------------------------------------------------------
__EXPORT_TYPE1 long GetObjectTypeIdByName(WideString Name);
__EXPORT_TYPE1 TList* GetObjectTypeIdList(); // delete the list after use!
__EXPORT_TYPE1 TList* GetPropertyTypeIdList(long ObjTypeId); // inherited included, delete the list after use!

// if ObjTypeId = 0, returns the list of ALL link types
__EXPORT_TYPE1 TList* GetLinkTypeIdList(long ObjTypeId); // inherited included, delete the list after use!

__EXPORT_TYPE1 long GetExtendsId(long ObjTypeId);
__EXPORT_TYPE1 TList* GetExtendsIdList(long ObjTypeId); // in ascending order, delete the list after use!
__EXPORT_TYPE1 int ExtendsExtends(long SubTypeId, long SuperTypeId); // SubTypeId != SuperTypeId, returns 1 or 0
__EXPORT_TYPE1 TList* GetExtensionIdList(long ObjTypeId); // delete the list after use!
__EXPORT_TYPE1 void AddTotalExtensionIdList(long ObjTypeId, TList *idList); // does not add ObjTypeId itself!
__EXPORT_TYPE1 void AddRealExtensionIdList(long ObjTypeId, TList *idList); // adds ObjTypeId itself - if real!
__EXPORT_TYPE1 int InstancesReadOnly(long ObjectTypeId);
__EXPORT_TYPE1 int GetObjectTypeAttributes1(long ObjectTypeId, WideString &Name, WideString &Description,
            long &ExtendsTypeId);  // 0 - error
//__EXPORT_TYPE1 int GetObjectTypeHelpData(long ObjectTypeId, WideString &HelpFileName, long &HelpContextId);  // 0 - error
//__EXPORT_TYPE1 WideString GetObjectTypeIconFileName(long ObjectTypeId);

__EXPORT_TYPE1 long CreateObjectType(long ExtendsTypeId, WideString Name, WideString Description); // returns id, or 0 - error
__EXPORT_TYPE1 int UpdateObjectType1(long ExtendsTypeId, long ObjectTypeId, WideString Name, WideString Description); // 0 - error

__EXPORT_TYPE1 int AddPropertyType(long ObjectTypeId, long PropertyTypeId); // 0 - error
__EXPORT_TYPE1 int RemovePropertyType(long ObjectTypeId, long PropertyTypeId); // 0 - error
__EXPORT_TYPE1 int CanDetachPropertyType(long ObjectTypeId, long PropertyTypeId, char Messages);

//__EXPORT_TYPE1 int SetAsPrimaryKey(long ObjectTypeId, long TypeId); // property or link type
//__EXPORT_TYPE1 int UnsetAsPrimaryKey(long ObjectTypeId, long TypeId); // property or link type

__EXPORT_TYPE1 int CanDeleteObjectType(long ObjectTypeId, char Messages); // 0 - do not issue error messages
__EXPORT_TYPE1 int DeleteObjectType(long ObjectTypeId); // 0 - error

//------------------------------------------------------------------------------
// PROPERTY TYPES
//------------------------------------------------------------------------------
__EXPORT_TYPE1 long GetPropertyTypeIdByName(long ObjTypeId, WideString Name); // 0 - error

__EXPORT_TYPE1 int IsPropertyMandatory(long PropertyTypeId);
__EXPORT_TYPE1 int GetPropertyTypeAttributes1(long PropertyTypeId, char &BaseType, char &Cardinality,
                    WideString &DefaultValue); // 0 - error
__EXPORT_TYPE1 long CreatePropertyType1(WideString Name, WideString Description, char BaseType,
                    char Cardinality, WideString DefaultValue); // returns id, or 0 - error
__EXPORT_TYPE1 int UpdatePropertyType1(long PropertyTypeId, WideString Name, WideString Description, char BaseType,
                    char Cardinality, WideString DefaultValue); // 0 - error
__EXPORT_TYPE1 int CanDeletePropertyType(long PropertyTypeId, char Messages); // 0 - do not issue error messages
__EXPORT_TYPE1 int DeletePropertyType(long PropertyTypeId); // 0 - error
__EXPORT_TYPE1 char GetPropertyBaseType(long PropertyTypeId);
__EXPORT_TYPE1 int GetPropertyTypeAttributesMain(long PropertyTypeId, char &BaseType, char &Cardinality); // 0 - error
__EXPORT_TYPE1 int GetEnumNameNum(long PropertyTypeId);
__EXPORT_TYPE1 WideString GetEnumNameByIndex(long PropertyTypeId, int Index); // returns "" on error
__EXPORT_TYPE1 int GetEnumValueByName(long PropertyTypeId, WideString Name); // returns -1 on error
__EXPORT_TYPE1 WideString GetEnumNameByValue(long PropertyTypeId, int Value); // returns "" on error
__EXPORT_TYPE1 int SetEnum(long PropertyTypeId, WideString Name, int Value=-1); // returns -1 on error

//------------------------------------------------------------------------------
// LINK TYPES
//------------------------------------------------------------------------------
__EXPORT_TYPE1 long GetLinkTypeIdByName(long ObjTypeId, WideString Name); // 0 - error

__EXPORT_TYPE1 int GetInverseLinkTypeId(long LinkTypeId); // 0 - error

__EXPORT_TYPE1 int GetLinkTypeAttributes1(long LinkTypeId,
                   long &SideObjTypeId1, char &Cardinality1,
                   long &SideObjTypeId2, char &Cardinality2,
                   long &InverseLinkTypeId); // 0 - error
__EXPORT_TYPE1 int GetLinkTypeAttributes2(long LinkTypeId,
                           long &SideObjTypeId1, char &Cardinality1, char &Role1,
                           long &SideObjTypeId2, char &Cardinality2, char &Role2,
                           long &InverseLinkTypeId); // 0 - error
__EXPORT_TYPE1 int GetLinkTypeAttributes3(long LinkTypeId,
                           long &SideObjTypeId1, char &Cardinality1, char &Role1, char &Ordered1,
                           long &SideObjTypeId2, char &Cardinality2, char &Role2, char &Ordered2,
                           long &InverseLinkTypeId); // 0 - error

__EXPORT_TYPE1 long CreateLinkType(WideString Name, WideString Description, WideString InverseName,
                    long ObjectTypeId1, char Cardinality1, char Role1, char Ordered1,
                    long ObjectTypeId2, char Cardinality2, char Role2, char Ordered2 ); // 0 - error

__EXPORT_TYPE1 int UpdateLinkType2(long LinkTypeId, WideString Name, WideString InverseName);

__EXPORT_TYPE1 int CanDeleteLinkType(long LinkTypeId, char Messages); // 0 - do not issue error messages
__EXPORT_TYPE1 int DeleteLinkType(long LinkTypeId);  // 0 - error

//------------------------------------------------------------------------------
// PACKAGES
//------------------------------------------------------------------------------
__EXPORT_TYPE1 long GetPackageIdByName(WideString Name);
__EXPORT_TYPE1 long CreatePackage(WideString Name, WideString Description, char ReadOnly); // returns id, or 0 - error
__EXPORT_TYPE1 int UpdatePackage(long PackageId, WideString Name, WideString Description, char ReadOnly); // 0 - error
__EXPORT_TYPE1 int CanDeletePackage(long PackageId, char Messages); // 0 - do not issue error messages
__EXPORT_TYPE1 int DeletePackage(long PackageId); // 0 - error
__EXPORT_TYPE1 int SetPackage(long TypeId, long PackageId);
__EXPORT_TYPE1 long GetPackageId(long TypeId, WideString &PackageName);
__EXPORT_TYPE1 int GetPackageAttributes(long PackageId, WideString &Name, WideString &Description,
                   char &ReadOnly);  // 0 - error

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// RETRIEVING OBJECTS, PROPERTIES, LINKS
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

__EXPORT_TYPE1 int __fastcall CheckPropertyValue(long PropertyTypeId, WideString Value);

// Scanning objects by types
__EXPORT_TYPE1 int GetObjectNum(long ObjectTypeId);
__EXPORT_TYPE1 long GetObjectIdByIndex(long ObjectTypeId, int Index);

// returns 0 or 1
__EXPORT_TYPE1 int ObjectExists(long ObjectId);

// Retrieving object properties
// object type
__EXPORT_TYPE1 long GetObjectTypeId(long ObjectId); // 0 - error
// empty value means "no property"
__EXPORT_TYPE1 WideString GetPropertyValue(long ObjectId, long PropertyTypeId);

// Retrieving objects linked to the given object
// cardinality 0..1
__EXPORT_TYPE1 long GetLinkedObjectId(long ObjectId, long LinkTypeId);
// cardinality 0..N
__EXPORT_TYPE1 int GetLinkedObjectNum(long ObjectId, long LinkTypeId);
// Index starts from 0
__EXPORT_TYPE1 long GetLinkedObjectIdByIndex(long ObjectId, long LinkTypeId, int Index);

// Retrieving objects by property values - be careful! - performance problems possible!
// returns one object id
__EXPORT_TYPE1 long GetObjectIdByPropertyValue(long ObjectTypeId,
                                               long PropertyTypeId, WideString Value);
// returns Tlist of object ids (delete the list after use!)
__EXPORT_TYPE1 TList* GetObjectIdListByPropertyValue(long ObjectTypeId,
                              long PropertyTypeId, WideString Value);

// if LinkTypeList = NULL or empty, returns the list {ObjectId};
__EXPORT_TYPE1 TList* GetPartnerObjectList(long ObjectId, TList *LinkTypeList);

// Retrieving objects by links
// ParamList = { LinkTypeId11, LinkTypeId12, LinkTypeId13, PartnerId1,
//               LinkTypeId21, LinkTypeId22, PartnerId2,
//               LinkTypeId31, PartnerId3,
//               etc.
__EXPORT_TYPE1 TList* GetObjectIdListByLinksA(long ObjectTypeId, TList *ParamList);

// Retrieving objects by links
// Set LinkTypeId4 = 0 to search by 3 links
// Set LinkTypeId3 = 0 and LinkTypeId4 = 0to search by 2 links
// Set LinkTypeId2 = 0 and LinkTypeId3 = 0 and LinkTypeId4 to search by a single link
// returns Tlist of object ids (delete the list after use!)
__EXPORT_TYPE1 TList* GetObjectIdListByLinks(long ObjectTypeId,
                              long LinkTypeId1, long PartnerId1,
                              long LinkTypeId2, long PartnerId2,
                              long LinkTypeId3, long PartnerId3,
                              long LinkTypeId4, long PartnerId4);

// Are two objects coonected by the given link type?
__EXPORT_TYPE1 int AlreadyConnected(long LinkTypeId, long ObjectId1, long ObjectId2);

// Start object deletion registration
__EXPORT_TYPE1 int StartObjectDeletionRegistration(void);
// Stop  object deletion registration
__EXPORT_TYPE1 int StopObjectDeletionRegistration(void);
// Get deleted object ID list -- DO NOT delete list after use!!!
__EXPORT_TYPE1 TList* GetDeletedObjectIDList(void);


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// CREATING, UPDATING OBJECTS, PROPERTIES, LINKS
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

// Creating/updating/deleting objects
__EXPORT_TYPE1 long CreateObject(long ObjectTypeId); // returns objId, 0 - on error
__EXPORT_TYPE1 int AddProperty(long ObjectId, long PropertyTypeId, WideString Value); // 0 - error
//__EXPORT_TYPE1 int AddPropertyN(long ObjectId, long PropertyTypeId, WideString Value); // do not use!!!
//__EXPORT_TYPE1 int DeletePropertyValue(long ObjectId, long PropertyTypeId, WideString Value); // obsolete, do not use!
// Deletes all property values of this type
__EXPORT_TYPE1 int DeleteProperty(long ObjectId, long PropertyTypeId); // 0 - error
// Removes all links, deletes object
__EXPORT_TYPE1 int DeleteObjectHard(long ObjectId); // 0 - error

// If ObjectId2==0, deletes all links of this type
// If link cardinality (on any side) is Card_01 or Card_1, replaces the previous link of this type
__EXPORT_TYPE1 int CreateLink(long LinkTypeId, long ObjectId1, long ObjectId2); // 0 - error
// For ordered one-to-many links
// Position = 0, 1, 2, ..., -1 means "append as last"
// CreateLink is equivalent to CreateLink1 with Position = -1
__EXPORT_TYPE1 int CreateLink1(long LinkTypeId, long ObjectId1, long ObjectId2, int Position);
// Obsolete! Works as CreateLink
//__EXPORT_TYPE1 int UpdateLink1(long LinkTypeId, long ObjectId1, long ObjectId2); // 0 - error

// If ObjectId2==0, deletes all links of this type
__EXPORT_TYPE1 int DeleteLink(long LinkTypeId, long ObjectId1, long ObjectId2); // 0 - error

// deletes all links of this type starting at ObjectId1
// Obsolete! Works as DeleteLink(LinkTypeId, ObjectId1, 0)
//__EXPORT_TYPE1 int DeleteLinkA(long LinkTypeId, long ObjectId1); // 0 - error

// deletes all links of this type starting at ObjectId1,
// and all the corresponding partner objects
__EXPORT_TYPE1 int DeleteLinkB(long LinkTypeId, long ObjectId1); // 0 - error

// For ordered one-to-many links
// Positions = 0, 1, 2, ...
// Returns 0 on error
__EXPORT_TYPE1 int ExchangeLinks(long ObjectId, long LinkTypeId, int Position1, int Position2);

//------------------------------------------------------------------------------
__EXPORT_TYPE1 int SaveRequest(int Tool);

#define Tool_MetamodelEditor 1
//#define Tool_EditorConfigurator 2
//#define Tool_UserConfigurationEditor 3
//#define Tool_DiagramConfigurator_All 4
//#define Tool_DiagramConfigurator_User 5
//#define Tool_DiagramConfigurator_Starting 41
//#define Tool_TreeManager_SaveProject 6
#define Tool_DataManager_CloseProject 7
//#define Tool_DataManager_StoreDataInDatabase 8
//#define Tool_DataManager_Internal_DoNotAsk 9
#define Tool_DataManager_Internal_Ask 10
#define Tool_DataManager_Internal_Save 11
#define Tool_DataManager_Internal_DoNotSave 12

//#define Tool_External 99

//------------------------------------------------------------------------------
// Transaction management
//------------------------------------------------------------------------------
// Use these two functions at start and after the end of any object update process,
// for example, when processing the Save-button-click.
// Otherwise your modifications will be ignored!
#define ect_SaveOperation_Create 1
#define ect_SaveOperation_Update 2
#define ect_SaveOperation_Delete 3
#define ect_SaveOperation_Move 4
#define ect_SaveOperation_SaveDiagram 5

// Returns: 0 on error, transaction id on success
__EXPORT_TYPE1 int StartSaveTransaction1(char Operation, long ObjectId, WideString Text);

// If CommitSaveTransaction returns 0, the transaction has been ignored (and rolled back)
__EXPORT_TYPE1 int CommitSaveTransaction();

// Rolls back UNCOMMITTED transaction
//__EXPORT_TYPE1 int RollbackSaveTransaction();

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Repository, export, import
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

__EXPORT_TYPE1 int ConnectRepository4(WideString FilePath); // returns 0 on error
__EXPORT_TYPE1 int DisconnectRepository4(); // returns 0 on error

__EXPORT_TYPE1 int ImportDataFromXMLFile(TComponent* Owner); // returns 0 on error or cancel

__EXPORT_TYPE1 void ExportXML(void* ParamBlock);
__EXPORT_TYPE1 long ImportXML(void* ParamBlock);

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Project management
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
#define ect_RepositoryType_FileX 1
//#define ect_RepositoryType_Tables 2
//#define ect_RepositoryType_ECR 3

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// RAZNOJE
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

//__EXPORT_TYPE1 WideString GetECTMainSoftwareRoot();    // renamed as GetMainSoftwareRoot()
__EXPORT_TYPE1 WideString GetMainSoftwareRoot();

//__EXPORT_TYPE1 AnsiString ECT_WideStringToAnsiString(int Charset, const WideString& ws);
//__EXPORT_TYPE1 WideString ECT_AnsiStringToWideString(int Charset, const AnsiString& as);
//__EXPORT_TYPE1 int ECT_SetFont(TFont *Font); // 1 - modified, 0 - not modified

//__EXPORT_TYPE1 void AddToWideStringList(void *List, WideString Str);
//__EXPORT_TYPE1 void DeleteWideString(WideString *Str);

//------------------------------------------------------------------------------
// ITERATORS
//------------------------------------------------------------------------------

__EXPORT_TYPE1 long CreateIteratorObjT(long ObjectTypeId);  // > 0 IteratorId, 0 - error
__EXPORT_TYPE1 long CreateIteratorObjLinkT(long ObjectId, long LinkTypeId1,
                                                  long LinkTypeId2 = 0,
                                                  long LinkTypeId3 = 0,
                                                  long LinkTypeId4 = 0,
                                                  long LinkTypeId5 = 0); // > 0 IteratorId, 0 - error
__EXPORT_TYPE1 long DeleteIterator(long IteratorId);    // 1 - OK, 0 - error (no iterator with such Id)
__EXPORT_TYPE1 long GetNextObjectId(long IteratorId);   // > 0 ObjectId, 0 - error


//------------------------------------------------------------------------------
// Resource References
//------------------------------------------------------------------------------
/*
#define PickRef_Option_ShowOwners 1
#define PickRef_Option_NoShowTypes 2
#define PickRef_Option_ReducedDialog 4
#define PickRef_Option_ShowPartsOnly 8
#define PickRef_Option_AddGroupName 16
#define PickRef_Option_AddGroupParts 32
#define PickRef_Option_FullExpand 64
*/

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//#ifndef __BUILDING_ECT_DATA_DLL
// handling object identifiers
//#define maxNonUniqueId 1000000L
//#define shiftNonUniqueId 1000000000L
//#define warningIdLimit 100L
//#endif
//------------------------------------------------------------------------------

#endif
