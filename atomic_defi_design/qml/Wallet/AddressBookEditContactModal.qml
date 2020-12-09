//! Qt
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Universal 2.15
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

//! Deps
import Qaterial 1.0 as Qaterial

//! Project
import "../Components"
import "../Constants"

BasicModal {
    id: root
    width: 500

    ModalContent {
        Layout.topMargin: 5
        Layout.fillWidth: true

        title: qsTr("Edit contact")

        //! Contact name section
        TextFieldWithTitle {
            id: name_input
            width: 30
            title: qsTr("Contact Name")
            field.placeholderText: qsTr("Enter a contact name")
            field.text: modelData.name
            field.onTextChanged: {
                const max_length = 50
                if (field.text.length > max_length)
                    field.text = field.text.substring(0, max_length)
            }
        }

        //! Wallets information
        ColumnLayout {
            Layout.fillWidth: true

            //! Title
            TitleText {
                text: qsTr("Wallets Information")
            }

            //! Wallets information type selection list
            DefaultComboBox {
                id: wallet_info_type_select

                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter

                model: modelData
                textRole: "type"
                mainLineText: currentValue.type
            }

            //! Wallet information edition
            TableView {
                id: wallet_info_table
                model: wallet_info_type_select.currentValue

                Layout.topMargin: 15
                Layout.fillWidth: true

                backgroundVisible: false

                headerDelegate: DefaultRectangle {
                }

                rowDelegate: DefaultRectangle {
                    id: wallet_info_row_rect

                    height: 35
                    radius: 0
                    color: styleData.selected ? Style.colorBlue : styleData.alternate ? Style.colorRectangle : Style.colorRectangleBorderGradient2
                }

                //! Key column
                TableViewColumn {
                    id: wallet_info_key_column

                    width: 170

                    role: "key"
                    title: "Key"

                    delegate: RowLayout {
                        DefaultText {
                            text: styleData.value
                            font.pixelSize: Style.textSizeSmall4
                        }
                    }
                }
                //! Address column
                TableViewColumn {
                    id: wallet_info_value_column

                    width: 200

                    role: "value"
                    title: "Address"

                    delegate: RowLayout {
                        //! Text value
                        DefaultText {
                            text: styleData.value
                            font.pixelSize: Style.textSizeSmall4
                        }
                    }
                }

                TableViewColumn {
                    role: "value"
                    title: "Address"

                    delegate: Row {
                        spacing: 0

                        //! Copy clipboard button
                        Qaterial.OutlineButton {
                            implicitHeight: 35
                            implicitWidth: 35

                            icon.source: Qaterial.Icons.contentCopy

                            onClicked: {
                                API.qt_utilities.copy_text_to_clipboard(styleData.value)
                            }
                        }

                        //! Send button
                        Qaterial.OutlineButton {
                            implicitHeight: 35
                            implicitWidth: 35

                            icon.source: Qaterial.Icons.send

                            onClicked: {
                                console.log("Send button");
                            }
                        }
                    }
                }
            }

            //! Wallet information buttons
            RowLayout {
                //! Wallet address creation
                PrimaryButton {
                    text: qsTr("Add")

                    onClicked: {
                        wallet_info_address_creation.open();
                    }
                }

                //! Wallet address deletion
                DangerButton {
                    text: qsTr("Remove")

                    onClicked: {
                        if (wallet_info_table.currentRow >= 0)
                        {
                            wallet_info_type_select.currentValue.remove_address_entry(wallet_info_table.currentRow)
                        }
                    }
                }
            }

            AddressBookAddContactAddressModal {
                id: wallet_info_address_creation
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Categories section title
        TitleText {
            text: qsTr("Tags")
        }

        //! Category adding form
        AddressBookNewContactCategoryModal {
            id: add_category
        }

        //! Categories list
        Flow {
            Layout.fillWidth: true

            Repeater {
                id: category_repeater
                model: modelData.categories

                property var contactModel: modelData

                Qaterial.OutlineButton {
                    Layout.alignment: Qt.AlignLeft
                    Layout.leftMargin: 4

                    text: modelData
                    icon.source: Qaterial.Icons.closeOctagon

                    onClicked: {
                        category_repeater.contactModel.remove_category(modelData);
                    }
                }
            }


            //! Category adding form opening button
            Qaterial.OutlineButton {
                Layout.leftMargin: 10

                text: qsTr("+")

                onClicked: {
                    add_category.open();
                }
            }
        }

        HorizontalLine {
            Layout.fillWidth: true
            color: Style.colorWhite8
        }

        //! Validate contact changes and cancel buttons
        RowLayout {
            Layout.alignment: Qt.AlignBottom | Qt.AlignRight
            Layout.rightMargin: 15

            //! Validate
            PrimaryButton {
                text: qsTr("Validate")
                onClicked: {
                    root.close();
                    modelData.name = name_input.field.text
                    modelData.save();
                }
            }

            //! Cancel
            DefaultButton {
                text: qsTr("Cancel")
                onClicked: {
                    wallet_info_type_select.currentIndex = 0;
                    root.close();
                    name_input.field.text = modelData.name;
                    modelData.reload();
                }
            }
        }
    }
}
