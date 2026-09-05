cmake_minimum_required(VERSION 3.16)

project(flatulence VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
# set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.10)

# Content of downloaded design from Figma to Qt or similar
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/importedcontent/CMakeLists.txt")
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/importedcontent)
endif()

qt_add_executable(appflatulence
    main.cpp
)

qt_add_qml_module(appflatulence
    URI flatulence
    QML_FILES
        Main.qml
        SOURCES NetworkManagerTest.h NetworkManagerTest.cpp
        SOURCES FileHelper.h FileHelper.cpp
        SOURCES TranferSenderTest.h TranferSenderTest.cpp
        SOURCES TransferReceiverTest.h TransferReceiverTest.cpp
        SOURCES ConnectionHandler.h ConnectionHandler.cpp
        QML_FILES ScrollContainer.qml
        QML_FILES AppSplitView.qml
        RESOURCES
        "assets/images/computer.png"
        "assets/images/laptop.png"
        "assets/images/phone.png"
        "assets/images/Bin.png"
        "assets/images/remove.png"
          "assets/images/import.png"

)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appflatulence PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appflatulence
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appflatulence
    PRIVATE Qt6::Quick
)

install(TARGETS appflatulence
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
