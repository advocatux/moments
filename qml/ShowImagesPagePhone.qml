import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.3
import Ubuntu.Layouts 1.0
import Ubuntu.Components.ListItems 1.3 as ListItem
/* a custom plugin */
import Fileutils 1.0

import QtQuick.LocalStorage 2.0
import "./js/Storage.js" as Storage

/* import folder */
import "./dialog"

/*
  Show the images associated with a Moment PHONE version
*/
Page {
     id: showImagesPage

     /* Values passed as input properties when a Moment is selected form the list */
     property string id;
     property string title;

     /* info for currently selected image in the GridView: updated each time user select an image */
     property string targetImageName;
     property string targetMomentId;
     property string imageListModelIndex;

     header: PageHeader {
        title: i18n.tr("Images for")+": "+ showImagesPage.title
     }

     Component {
         id: imageZoomtDialogue
         ImageZoomDialog{targetImageName:Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images/"+showImagesPage.targetImageName}
     }

     Component {
         id: removeImageDialog
         RemoveImageDialog{targetImageName:Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images/"+showImagesPage.targetImageName; targetMomentId: showImagesPage.id; imageListModelIndex: showImagesPage.imageListModelIndex}
     }

     /* fill model with the images associated with the moment */
     Component.onCompleted: {

         console.log("showImagesPage loading images for moment with id:"+showImagesPage.id)

         var imagePath = Fileutils.getHomePath()+"/"+root.imagesSavingRootPath+"/moments/"+showImagesPage.title+"/images";
         console.log("showImagesPage search path is: "+imagePath);

         var fileList = Fileutils.getMomentImages(imagePath);
         momentsImagesListModel.clear();

         for(var i=0; i<fileList.length; i++) {
            momentsImagesListModel.append( { imageName: fileList[i], imagePath: imagePath, value:i } );
         }

         if(momentsImagesListModel.count > 0){
            removeButton.enabled = true;
            zoomButton.enabled = true;
            /* set as target the first image */
            showImagesPage.targetImageName = momentsImagesListModel.get(0).imageName;
            showImagesPage.targetMomentId = id;
         }

         console.log("showImagesPage Found images: "+ momentsImagesListModel.count);
     }

     /* highlighter Component for currently selected image in the GridView */
     Component {
          id: highlightComponent
          Rectangle {
               width: imageGridView.cellWidth
               height: imageGridView.cellHeight
               color: "blue"; radius: 5
               x: imageGridView.currentItem.x
               y: imageGridView.currentItem.y
               Behavior on x { SpringAnimation { spring: 3; damping: 0.2 } }
               Behavior on y { SpringAnimation { spring: 3; damping: 0.2 } }
          }
     }

     Column{
           anchors.fill: parent
           spacing: units.gu(2)

           /* transparent placeholder */
           Rectangle {
                color: "transparent"
                width: parent.width
                height: units.gu(6)
           }

           Row{
              anchors.horizontalCenter: parent.horizontalCenter
              Label {
                  text: i18n.tr("Images Found")+": "+momentsImagesListModel.count
                  fontSize: "medium"
              }
           }

           GridView {
                id: imageGridView
                width: parent.width
                height: parent.height - parent.height/4
                cellWidth: parent.width/3
                cellHeight: parent.height/4
                model: momentsImagesListModel
                delegate: ShowImageDelegate{}
                highlight: highlightComponent
                highlightFollowsCurrentItem: false
                focus: true
                clip: true
           }

           Row{
               id:commandButtonsRow
               spacing: units.gu(2)
               anchors.horizontalCenter: parent.horizontalCenter

               Button{
                   id: zoomButton
                   enabled: false
                   text: i18n.tr("Zoom")
                   width: units.gu(20)
                   color: UbuntuColors.green
                   onClicked: {
                      PopupUtils.open(imageZoomDialog)
                   }
               }

               Button{
                  id: removeButton
                  enabled: false
                  text: i18n.tr("Remove")
                  width: units.gu(20)
                  color: UbuntuColors.red
                  onClicked: {
                     showImagesPage.imageListModelIndex = imageGridView.currentIndex
                     PopupUtils.open(removeImageDialog)
                  }
               }
           }

           /* To show a scrolbar on the side */
           Scrollbar {
               flickableItem: imageGridView
               align: Qt.AlignBottom
           }

    } //col
}
