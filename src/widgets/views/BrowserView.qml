// Copyright 2018-2020 Camilo Higuita <milo.h@aol.com>
// Copyright 2018-2020 Nitrux Latinoamericana S.C.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick 2.13
import QtQuick.Controls 2.13

import org.kde.kirigami 2.14 as Kirigami
import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.0 as FB

Maui.Page
{
    id: control

    property alias selectionBar: _selectionBar
    property alias currentTabIndex : _browserList.currentIndex
    property alias currentTab : _browserList.currentItem
    property alias browserList : _browserList

    showCSDControls: true
    floatingFooter: true

    headBar.rightContent:[

        Maui.ToolButtonMenu
        {
            icon.name: currentBrowser.settings.viewType === FB.FMList.LIST_VIEW ? "view-list-details" : "view-list-icons"

            Maui.LabelDelegate
            {
                width: parent.width
                isSection: true
                label: i18n("View type")
            }

            MenuItem
            {
                text: i18n("List")
                icon.name: "view-list-details"
                autoExclusive: true
                checked: currentBrowser.settings.viewType === FB.FMList.LIST_VIEW
                checkable: true
                onTriggered:
                {
                    if(currentBrowser)
                    {
                        currentBrowser.settings.viewType = FB.FMList.LIST_VIEW
                    }

                    settings.viewType = FB.FMList.LIST_VIEW
                }
            }

            MenuItem
            {
                text: i18n("Grid")
                icon.name: "view-list-icons"
                autoExclusive: true
                checked:  currentBrowser.settings.viewType === FB.FMList.ICON_VIEW
                checkable: true
                onTriggered:
                {
                    if(currentBrowser)
                    {
                        currentBrowser.settings.viewType = FB.FMList.ICON_VIEW
                    }

                    settings.viewType = FB.FMList.ICON_VIEW
                }
            }

            MenuSeparator {}

            Maui.LabelDelegate
            {
                width: parent.width
                isSection: true
                label: i18n("Sort by")
            }

            MenuItem
            {
                text: i18n("Type")
                checked: currentBrowser.currentFMList.sortBy === FB.FMList.MIME
                checkable: true
                onTriggered: currentBrowser.settings.sortBy = FB.FMList.MIME
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Date")
                checked: currentBrowser.currentFMList.sortBy === FB.FMList.DATE
                checkable: true
                onTriggered: currentBrowser.settings.sortBy = FB.FMList.DATE
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Modified")
                checkable: true
                checked: currentBrowser.currentFMList.sortBy === FB.FMList.MODIFIED
                onTriggered: currentBrowser.settings.sortBy = FB.FMList.MODIFIED
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Size")
                checkable: true
                checked: currentBrowser.currentFMList.sortBy === FB.FMList.SIZE
                onTriggered: currentBrowser.settings.sortBy = FB.FMList.SIZE
                autoExclusive: true
            }

            MenuItem
            {
                text: i18n("Name")
                checkable: true
                checked: currentBrowser.currentFMList.sortBy === FB.FMList.LABEL
                onTriggered: currentBrowser.settings.sortBy = FB.FMList.LABEL
                autoExclusive: true
            }

            MenuSeparator{}

            MenuItem
            {
                text: i18n("Show Folders First")
                checked: currentBrowser.currentFMList.foldersFirst
                checkable: true
                onTriggered: currentBrowser.settings.foldersFirst = !currentBrowser.settings.foldersFirst
            }

            MenuItem
            {
                id: groupAction
                text: i18n("Group")
                checkable: true
                checked: currentBrowser.settings.group
                onTriggered:
                {
                    currentBrowser.settings.group = !currentBrowser.settings.group
                }
            }
        }
     ]

    headBar.farLeftContent: ToolButton
    {
//        visible: placesSidebar.collapsed
        icon.name: placesSidebar.visible ? "sidebar-collapse" : "sidebar-expand"
        onClicked: placesSidebar.toggle()
        checked: placesSidebar.visible
        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: i18n("Toogle SideBar")
    }

    footer: Maui.SelectionBar
    {
        id: _selectionBar

        padding: Maui.Style.space.big
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        maxListHeight: _browserList.height - (Maui.Style.contentMargins*2)

        onCountChanged:
        {
            if(_selectionBar.count < 1)
            {
                root.selectionMode = false
            }
        }

        onUrisDropped:
        {
            for(var i in uris)
            {
                if(!FB.FM.fileExists(uris[i]))
                    continue;

                const item = FB.FM.getFileInfo(uris[i])
                _selectionBar.append(item.path, item)
            }
        }

        onExitClicked: clear()

        listDelegate: Maui.ListBrowserDelegate
        {
            isCurrentItem: false
            Kirigami.Theme.inherit: true
            width: ListView.view.width
            height: Maui.Style.iconSizes.big + Maui.Style.space.big
            imageSource: root.showThumbnails ? model.thumbnail : ""
            iconSource: model.icon
            label1.text: model.label
            label2.text: model.path
            label3.text: ""
            label4.text: ""
            checkable: true
            checked: true
            iconSizeHint: Maui.Style.iconSizes.big
            onToggled: _selectionBar.removeAtIndex(index)
            background: Item {}
            onClicked:
            {
                _selectionBar.selectionList.currentIndex = index
            }

            onPressAndHold: removeAtIndex(index)
        }

        Action
        {
            text: i18n("Open")
            icon.name: "document-open"
            onTriggered:
            {
                for(var i in selectionBar.uris)
                    currentBrowser.openFile(_selectionBar.uris[i])
            }
        }

        Action
        {
            text: i18n("Compress")
            icon.name: "archive-insert"
            onTriggered:
            {
                dialogLoader.sourceComponent= _compressDialogComponent
                dialog.urls = selectionBar.uris
                dialog.open()
            }
        }

        Action
        {
            text: i18n("Tags")
            icon.name: "tag"
            onTriggered:
            {
                tagFiles(_selectionBar.uris)
            }
        }

        Action
        {
            text: i18n("Share")
            icon.name: "document-share"
            onTriggered:
            {
                shareFiles(_selectionBar.uris)
            }
        }

        Action
        {
            text: i18n("Copy")
            icon.name: "edit-copy"
            onTriggered:
            {
                _selectionBar.animate()
                currentBrowser.copy(_selectionBar.uris)
            }
        }

        Action
        {
            text: i18n("Cut")
            icon.name: "edit-cut"
            onTriggered:
            {
                _selectionBar.animate()
                currentBrowser.cut(_selectionBar.uris)
            }
        }

        Action
        {
            text: i18n("Remove")
            icon.name: "edit-delete"

            onTriggered:
            {
                currentBrowser.remove(_selectionBar.uris)
            }
        }
    }

    Maui.TabView
    {
        id: _browserList
        anchors.fill: parent

        onNewTabClicked: openTab(currentPath)

        onCloseTabClicked: closeTab(index)

        onCurrentItemChanged:
        {
            currentBrowser.currentView.forceActiveFocus()
        }
    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        z: parent.z -2
        onDropped:
        {
            const urls = drop.urls
            for(var i in urls)
            {
                const item = FB.FM.getFileInfo(urls[i])
                if(item.isdir == "true")
                {
                    control.openTab(urls[i])
                }
            }
        }
    }
}

